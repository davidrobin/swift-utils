import Foundation

enum parseError: Error {
  case invalidText
  case invalidJson
}

func parseText(data: Data) throws -> String {
  guard let text = String(data: data, encoding: .utf8) else {
    throw parseError.invalidText
  }
  
  return text
}

func parseJson<T: Decodable>(data: Data, model: T.Type) throws -> T {
  do {
    return try JSONDecoder().decode(model.self, from: data)
  } catch {
    throw parseError.invalidJson
  }
}
