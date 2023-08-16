//
//  URLRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public protocol CampingURLRequest {
    
    static var method: HTTPMethod { get }
        
    static var contentType: String? { get }
    
    var body: Data? { get }
    
    func url(for server: CampingServer) -> URL
}

public protocol EncodableCampingURLRequest {
    
    associatedtype Body: Encodable
    
    var content: Body { get }
}

public extension CampingURLRequest {
    
    static var method: HTTPMethod { .get }
    
    static var contentType: String? { "application/json" }
}

extension EncodableCampingURLRequest {
    
    public var body: Data? {
        do {
            return try JSONEncoder.camping.encode(content)
        }
        catch {
            assertionFailure("Unable to encode \(self). \(error.localizedDescription)")
            return nil
        }
    }
}

public extension URLRequest {
    
    init<T: CampingURLRequest>(
        request: T,
        server: CampingServer
    ) {
        self.init(url: request.url(for: server))
        self.httpMethod = T.method.rawValue
        self.httpBody = request.body
    }
}

public extension URLClient {
    
    @discardableResult
    func request<Request>(
        _ request: Request,
        server: CampingServer,
        authorization authorizationToken: AuthorizationToken? = nil,
        statusCode: Int = 200,
        headers: [String: String] = [:]
    ) async throws -> Data where Request: CampingURLRequest {
        var urlRequest = URLRequest(
            request: request,
            server: server
        )
        if let token = authorizationToken {
            urlRequest.setAuthorization(token)
        }
        if let contentType = Request.contentType {
            urlRequest.addValue(contentType, forHTTPHeaderField: "Content-Type")
        }
        for (header, value) in headers.sorted(by: { $0.key < $1.key }) {
            urlRequest.addValue(value, forHTTPHeaderField: header)
        }
        let (data, urlResponse) = try await self.data(for: urlRequest)
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            fatalError("Invalid response type \(urlResponse)")
        }
        guard httpResponse.statusCode == statusCode else {
            throw CampingError.invalidStatusCode(httpResponse.statusCode)
        }
        return data
    }
}
