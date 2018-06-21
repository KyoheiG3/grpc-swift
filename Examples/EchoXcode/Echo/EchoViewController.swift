/*
 * Copyright 2016, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import AppKit
import SwiftGRPCClient
fileprivate typealias Stream = SwiftGRPCClient.Stream

class EchoViewController: NSViewController, NSTextFieldDelegate {
  @IBOutlet var messageField: NSTextField!
  @IBOutlet var sentOutputField: NSTextField!
  @IBOutlet var receivedOutputField: NSTextField!
  @IBOutlet var addressField: NSTextField!
  @IBOutlet var TLSButton: NSButton!
  @IBOutlet var callSelectButton: NSSegmentedControl!
  @IBOutlet var closeButton: NSButton!

  private var session: Session?

  private var serverStream: Stream<EchoServerRequest>?
  private var clientStream: Stream<EchoClientRequest>?
  private var bidiStream: Stream<EchoBidirectionalRequest>?

  private var nowStreaming = false

  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }

  private var enabled = false

  @IBAction func messageReturnPressed(sender _: NSTextField) {
    if enabled {
      do {
        try callServer(address: addressField.stringValue)
      } catch {
        print(error)
      }
    }
  }

  @IBAction func addressReturnPressed(sender _: NSTextField) {
    if nowStreaming {
      do {
        try sendClose()
      } catch {
        print(error)
      }
    }
    // invalidate the service
    session = nil
  }

  @IBAction func buttonValueChanged(sender _: NSSegmentedControl) {
    if nowStreaming {
      do {
        try sendClose()
      } catch {
        print(error)
      }
    }
  }

  @IBAction func closeButtonPressed(sender _: NSButton) {
    if nowStreaming {
      do {
        try sendClose()
      } catch {
        print(error)
      }
    }
  }

  override func viewDidLoad() {
    closeButton.isEnabled = false
    // prevent the UI from trying to send messages until gRPC is initialized
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
      self.enabled = true
    }
  }

  func displayMessageSent(_ message: String) {
    DispatchQueue.main.async {
      self.sentOutputField.stringValue = message
    }
  }

  func displayMessageReceived(_ message: String) {
    DispatchQueue.main.async {
      self.receivedOutputField.stringValue = message
    }
  }

  func prepareService(address: String) -> Session {
    if let session = self.session {
      return session
    }
    let session: Session
    if TLSButton.intValue == 0 {
      session = Session(address: address)
    } else {
      let certificateURL = Bundle.main.url(forResource: "ssl",
                                           withExtension: "crt")!
      let certificates = try! String(contentsOf: certificateURL)
      session = Session(address: address, certificates: certificates)
    }
//    if let service = service {
//      service.host = "example.com" // sample override
//      service.metadata = try! Metadata([
//        "x-goog-api-key": "YOUR_API_KEY",
//        "x-ios-bundle-identifier": Bundle.main.bundleIdentifier!
//      ])
//    }
    self.session = session
    return session
  }

  func callServer(address: String) throws {
    let session = prepareService(address: address)
    if callSelectButton.selectedSegment == 0 {
      // NONSTREAMING
      let unary = EchoUnaryRequest(text: messageField.stringValue)
      displayMessageSent(unary.text)
      session.stream(with: unary).data { result in
        switch result {
        case .success(let response):
          self.displayMessageReceived(response.text)
        case .failure(let error):
          self.displayMessageReceived("No message received. \(error)")
        }
      }
    } else if callSelectButton.selectedSegment == 1 {
      // STREAMING EXPAND
      if !nowStreaming {
        let server = EchoServerRequest(text: messageField.stringValue)
        displayMessageSent(server.text)
        serverStream = session.stream(with: server)
        serverStream?.receive { result in
          switch result {
          case .success(let response):
            if let message = response?.text {
              self.displayMessageReceived(message)
            }
          case .failure(let error):
            self.displayMessageReceived("No message received. \(error)")
          }
        }
      }
    } else if callSelectButton.selectedSegment == 2 {
      // STREAMING COLLECT
      if !nowStreaming {
        nowStreaming = true
        let client = EchoClientRequest()
        displayMessageSent(messageField.stringValue)
        clientStream = session.stream(with: client)
        clientStream?.send(messageField.stringValue) { result in
          if case .failure(let error) = result {
            self.displayMessageReceived("No message received. \(error)")
          }
        }
        DispatchQueue.main.async {
          self.closeButton.isEnabled = true
        }
      }
    } else if callSelectButton.selectedSegment == 3 {
      // STREAMING UPDATE
      if !nowStreaming {
        nowStreaming = true
        let bidi = EchoBidirectionalRequest()
        bidiStream = session.stream(with: bidi)
        bidiStream?.receive { result in
          switch result {
          case .success(let response):
            if let message = response?.text {
              self.displayMessageReceived(message)
            } else {
              self.displayMessageReceived("Done.")
            }
          case .failure(let error):
            self.displayMessageReceived("No message received. \(error)")
          }
        }
        DispatchQueue.main.async {
          self.closeButton.isEnabled = true
        }
        bidiStream?.send(messageField.stringValue) { result in
          if case .failure(let error) = result {
            self.displayMessageReceived("No message received. \(error)")
          }
        }
      }
    }
  }

  func sendClose() throws {
    bidiStream?.close { _ in
      self.bidiStream = nil
      self.nowStreaming = false
      DispatchQueue.main.async {
        self.closeButton.isEnabled = false
      }
    }
    clientStream?.closeAndReceive { result in
      switch result {
      case .success(let response):
        self.displayMessageReceived(response.text)
      case .failure(let error):
        self.displayMessageReceived("No message received. \(error)")
      }
      self.clientStream = nil
      self.nowStreaming = false
      DispatchQueue.main.async {
        self.closeButton.isEnabled = false
      }
    }
  }
}
