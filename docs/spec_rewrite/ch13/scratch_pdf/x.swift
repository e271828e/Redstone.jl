import PDFKit
let d = PDFDocument(url: URL(fileURLWithPath: CommandLine.arguments[1]))!
var s = ""
for i in 0..<d.pageCount { s += "\n=====PAGE \(i+1)=====\n" + (d.page(at:i)?.string ?? "") }
try! s.write(toFile: CommandLine.arguments[2], atomically: true, encoding: .utf8)
