//
//  URLResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 8/16/23.
//

import Foundation

/// Camping URL Response
public protocol CampingURLResponse: Decodable { }

public extension URLClient {
    
    func response<Request, Response>(
        _ response: Response.Type,
        for request: Request,
        server: CampingServer,
        authorization authorizationToken: AuthorizationToken? = nil,
        statusCode: Int = 200,
        headers: [String: String] = [:]
    ) async throws -> Response where Request: CampingURLRequest, Response: CampingURLResponse {
        var headers = headers
        headers["accept"] = "application/json"
        let data = try await self.request(
            request,
            server: server,
            authorization: authorizationToken,
            statusCode: statusCode,
            headers: headers
        )
        do {
            return try JSONDecoder.camping.decode(Response.self, from: data)
        } catch {
            #if DEBUG
            throw error
            #else
            throw CampingError.invalidResponse(data)
            #endif
        }
    }
}
