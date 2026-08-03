import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case server(status: Int, message: String?)
    case decoding(Error)
    case network(Error)
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid request URL."
        case .unauthorized: "Your session has expired. Please sign in again."
        case .server(let status, let message): message ?? "Server error (\(status))."
        case .decoding: "Couldn't read the server's response."
        case .network(let error): error.localizedDescription
        case .notConfigured: "No club server configured."
        }
    }
}

struct Empty: Codable {}

/// Centralized HTTP client for the active club's server. All requests carry
/// the stored Bearer token; a 401 triggers `onUnauthorized` so the app can
/// drop back to the login screen.
final class APIClient: @unchecked Sendable {
    static let shared = APIClient()
    private init() {}

    @MainActor var onUnauthorized: (() -> Void)?

    private let lock = NSLock()
    private var _baseURL: URL?
    private var _token: String?

    private var baseURL: URL? {
        lock.lock(); defer { lock.unlock() }
        return _baseURL
    }

    private var token: String? {
        lock.lock(); defer { lock.unlock() }
        return _token
    }

    func configure(baseURL: String, token: String?) {
        lock.lock()
        _baseURL = URL(string: baseURL)
        _token = token
        lock.unlock()
    }

    func updateToken(_ token: String?) {
        lock.lock(); _token = token; lock.unlock()
    }

    /// Resolves a server-relative path (e.g. from a `filename` the API gives
    /// back) against the active club's base URL, for building image/file URLs.
    func fileURL(_ path: String) -> URL? {
        baseURL?.appendingPathComponent(path)
    }

    // MARK: - Requests

    func get<T: Decodable>(_ path: String, query: [String: String] = [:]) async throws -> T {
        // Plain HTTP is subject to on-path caching by carriers/routers that
        // ignore Cache-Control entirely — a unique URL per request defeats
        // any cache keyed on the URL, regardless of where it sits.
        var bustedQuery = query
        bustedQuery["_"] = String(Int(Date().timeIntervalSince1970 * 1000))
        return try await send(path: path, method: "GET", query: bustedQuery, body: Optional<Empty>.none)
    }

    @discardableResult
    func post<T: Decodable>(_ path: String) async throws -> T {
        try await send(path: path, method: "POST", query: [:], body: Optional<Empty>.none)
    }

    @discardableResult
    func post<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await send(path: path, method: "POST", query: [:], body: body)
    }

    @discardableResult
    func put<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await send(path: path, method: "PUT", query: [:], body: body)
    }

    @discardableResult
    func delete<T: Decodable>(_ path: String) async throws -> T {
        try await send(path: path, method: "DELETE", query: [:], body: Optional<Empty>.none)
    }

    @discardableResult
    func delete<T: Decodable, B: Encodable>(_ path: String, body: B) async throws -> T {
        try await send(path: path, method: "DELETE", query: [:], body: body)
    }

    @discardableResult
    func deleteVoid(_ path: String) async throws -> Empty {
        try await send(path: path, method: "DELETE", query: [:], body: Optional<Empty>.none)
    }

    func upload<T: Decodable>(
        _ path: String,
        data: Data,
        fieldName: String,
        filename: String,
        mimeType: String,
        extraFields: [String: String] = [:]
    ) async throws -> T {
        guard let base = baseURL else { throw APIError.notConfigured }
        let url = base.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }

        var body = Data()
        for (key, value) in extraFields {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        return try await perform(request)
    }

    // MARK: - Internals

    private func send<T: Decodable, B: Encodable>(path: String, method: String, query: [String: String], body: B?) async throws -> T {
        guard let base = baseURL else { throw APIError.notConfigured }
        guard var components = URLComponents(url: base.appendingPathComponent(path), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = method
        // This app is always-online with no offline mode, and the server data
        // (field status, check-ins, messages, ...) changes from other clients
        // constantly — never let URLSession serve a stale cached response.
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body, !(body is Empty) {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONEncoder.rcclub.encode(body)
        }

        return try await perform(request)
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw APIError.network(error)
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.network(URLError(.badServerResponse))
        }

        if http.statusCode == 401 {
            Task { @MainActor in self.onUnauthorized?() }
            throw APIError.unauthorized
        }

        guard (200..<300).contains(http.statusCode) else {
            let message = try? JSONDecoder.rcclub.decode(APIErrorBody.self, from: data).message
            throw APIError.server(status: http.statusCode, message: message)
        }

        if T.self == Empty.self, let empty = Empty() as? T {
            return empty
        }

        do {
            return try JSONDecoder.rcclub.decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}

private struct APIErrorBody: Codable { let message: String? }

extension JSONDecoder {
    static let rcclub = JSONDecoder()
}

extension JSONEncoder {
    static let rcclub = JSONEncoder()
}
