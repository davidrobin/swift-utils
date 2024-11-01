# swift-utils

swift-utils aim to provide ready-to-use yet powerful Swift functions to perform complex tasks such as fetch various content (text, HTML, JSON...) or parse exotic language objects (JSON) to be Swift-compliant. Complexity abstracted, you can focus on fetch or parse your content without the hassle.

## Utils
So far I've crafted two utils that I found useful to be (re)used in my projects.

### fetch

As obvious its name is, `fetch` provides a method to retrieve content from a remote ressource, with any HTTP method that you might think of. You can eventually add optional headers to your request and a body if required, as a JSON object for now, the most common case nowadays.

### parse

This method allows you for now to transform a JSON object/array into a Swift equivalent, ready to be used along you code. As a prerequisite, you must first define a Model to detail the content you will retrieve, provide it to the function when calling it.

## Example

```swift
struct Content: Codable {
  let id: Int
  let content: String
  let type: String
}

func fetchContent(url: String = "https://api.example.com/get/content") async throws -> Content {
  var content: Content
  
  do {
    let req = try await fetch(
      url: url,
      type: "json"
    )
    
    content = try parseJson(data: req.data, model: Content.self)
  } catch {
    print("An Error has occured while trying to get content: \(error)")
    throw error
  }

  return content
}
```

Then inside a button action for instance, in a SwiftUI view:

```swift
...
Task {
  do {
    let contentData = try await fetchContent(url: "https://new.api.example.net/get/content")
                
    card.text = contentData.quote
    card.type = "- \(contentData.author)"
  } catch {
    self.errorMessage = "\(error)"
    self.showAlert = true
  }
}
...
```
