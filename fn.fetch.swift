import Foundation

enum fetchError: Error {
  case invalidStatusCode
  case invalidMimeType
  case invalidBody
  case unknownType
  case unknownMethod
  case urlNotSet
}

func fetch (
  url: String, type: String, method: String = "GET", headers: [String: String] = [:], body: [String: Any] = [:]
) async throws -> (
  statusCode: Int, mimeType: String, type: String, data: Data
) {
  
  let acceptedStatusCodes: ClosedRange = 200...299
  let acceptedMethods: [String] = ["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "CONNECT", "OPTIONS", "TRACE"]
  let mimeTypes: [String: String] = [
    "text": "text/plain",
    "html": "text/html",
    "json": "application/json"
  ]
  
  if !acceptedMethods.contains(method) {
    throw fetchError.unknownMethod
  }
  
  guard let mimeType: String = mimeTypes[type] else {
    throw fetchError.unknownType
  }
  
  guard let url = URL(string: url) else {
    throw fetchError.urlNotSet
  }
  
  var request = URLRequest(url: url)
  
  request.httpMethod = method
  
  request.setValue(mimeType, forHTTPHeaderField: "Accept")
  
  for (header, value) in headers {
    request.setValue(value, forHTTPHeaderField: header)
  }
  
  if (body.isEmpty == false && type == "json") {
    guard let jsonBody = try? JSONSerialization.data(withJSONObject: body) else {
      throw fetchError.invalidBody
    }
    
    request.setValue(mimeType, forHTTPHeaderField: "Content-Type")
    
    request.httpBody = jsonBody
  }

  let (data, response) = try await URLSession.shared.data(for: request)
  
  guard let httpResponse = response as? HTTPURLResponse,
  acceptedStatusCodes.contains(httpResponse.statusCode) else {
    throw fetchError.invalidStatusCode
  }
  
  if httpResponse.mimeType != mimeType {
    throw fetchError.invalidMimeType
  }
  
  return (
    statusCode: httpResponse.statusCode,
    mimeType: httpResponse.mimeType!,
    type: type,
    data: data
  )
}
