import XCTest
import HotwireNative

@MainActor
final class SignatureBridgeTests: XCTestCase {
    func test_componentName_isSignature() {
        XCTAssertEqual(SignatureBridge.name, "signature")
    }

    func test_didReceive_capturesCaptureMessage() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "capture",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let cached = bridge.receivedMessage(for: "capture")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached, message)
    }

    func test_didReceive_clearEvent_cachesMessage() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "clear",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let cached = bridge.receivedMessage(for: "clear")
        XCTAssertNotNil(cached)
    }

    func test_didReceive_unknownEvent_cachesButOnReceiveIgnores() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "unknown",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let cached = bridge.receivedMessage(for: "unknown")
        XCTAssertNotNil(cached)
    }

    func test_replyToError_withMessage_sendsReplyViaDelegate() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "error",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let errorMessage = "Signature cancelled"
        let expectation = expectation(description: "Reply sent")

        bridge.reply(to: "error", with: ["message": errorMessage]) { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertTrue(delegate.replyWithMessageWasCalled)
                XCTAssertEqual(delegate.replyWithMessageArg?.event, "error")
                XCTAssertTrue(
                    delegate.replyWithMessageArg?.jsonData.contains(errorMessage) ?? false
                )
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_onReceive_withCaptureEvent_doesNotCrash() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "capture",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.onReceive(message: message)
    }

    func test_onReceive_withClearEvent_doesNotCrash() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "clear",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.onReceive(message: message)
    }

    func test_onReceive_withUnknownEvent_doesNotCrash() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = SignatureBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "signature",
            event: "foobar",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.onReceive(message: message)
    }
}
