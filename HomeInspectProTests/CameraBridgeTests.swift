import XCTest
import HotwireNative

@MainActor
final class CameraBridgeTests: XCTestCase {
    func test_componentName_isCamera() {
        XCTAssertEqual(CameraBridge.name, "camera")
    }

    func test_didReceive_cachesCaptureMessage() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "capture",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let cached = bridge.receivedMessage(for: "capture")
        XCTAssertNotNil(cached)
        XCTAssertEqual(cached, message)
    }

    func test_didReceive_unknownEvent_cachesButOnReceiveIgnores() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "unknown",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let cached = bridge.receivedMessage(for: "unknown")
        XCTAssertNotNil(cached)
    }

    func test_replyToCapture_withDataURI_sendsReplyViaDelegate() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "capture",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let dataURI = "data:image/jpeg;base64,abc123"
        let expectation = expectation(description: "Reply sent")

        bridge.reply(to: "capture", with: ["image": dataURI]) { result in
            switch result {
            case .success(let success):
                XCTAssertTrue(success)
                XCTAssertTrue(delegate.replyWithMessageWasCalled)
                XCTAssertEqual(delegate.replyWithMessageArg?.event, "capture")
                XCTAssertTrue(
                    delegate.replyWithMessageArg?.jsonData.contains(dataURI) ?? false
                )
            case .failure(let error):
                XCTFail("Failed with error: \(error)")
            }
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func test_replyToError_withMessage_sendsReplyViaDelegate() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "error",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.didReceive(message: message)

        let errorMessage = "Camera permission denied"
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
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "capture",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.onReceive(message: message)
    }

    func test_onReceive_withUnknownEvent_doesNotCrash() {
        let destination = AppBridgeDestination()
        let delegate = BridgeDelegateSpy()
        let bridge = CameraBridge(destination: destination, delegate: delegate)
        let message = Message(
            id: "1",
            component: "camera",
            event: "foobar",
            metadata: nil,
            jsonData: "{}"
        )

        bridge.onReceive(message: message)
    }
}
