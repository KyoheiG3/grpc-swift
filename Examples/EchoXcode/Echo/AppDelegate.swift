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
import Cocoa
import SwiftGRPC
import SwiftGRPCServer

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  @IBOutlet var window: NSWindow!

  var echoProvider: Echo_EchoProvider!
  var insecureServer: ServiceServer!
  var secureServer: ServiceServer!

  var echoSession: Session?
  func applicationDidFinishLaunching(_: Notification) {
    echoSession = Session(address: "localhost:8888", provider: EchoProvider())
    echoSession?.start()
//    // instantiate our custom-written application handler
//    echoProvider = _EchoProvider()
//
//    // create and start a server for handling insecure requests
//    insecureServer = ServiceServer(address: "localhost:8081",
//                                   serviceProviders: [echoProvider])
//    insecureServer.start()
//    
//    // create and start a server for handling secure requests
//    let certificateURL = Bundle.main.url(forResource: "ssl", withExtension: "crt")!
//    let keyURL = Bundle.main.url(forResource: "ssl", withExtension: "key")!
//    secureServer = ServiceServer(address: "localhost:8443",
//                                 certificateURL: certificateURL,
//                                 keyURL: keyURL,
//                                 serviceProviders: [echoProvider])
//    secureServer.start()
  }
}
