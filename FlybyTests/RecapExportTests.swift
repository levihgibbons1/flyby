import CoreGraphics
import SwiftUI
import Testing
import UIKit
@testable import Flyby

struct RecapExportTests {
    @Test func exportSizesAreShareFriendly() {
        #expect(RecapCanvas.story.pixelSize == CGSize(width: 1080, height: 1920))
        #expect(RecapCanvas.square.pixelSize == CGSize(width: 1080, height: 1080))
        #expect(RecapCanvas.story.pointSize == CGSize(width: 360, height: 640))
        #expect(RecapCanvas.story.scale == 3)
    }

    @Test func noImageRenderedBeforeUserAction() {
        let spy = RecapRendererSpy()
        var session = RecapExportSession()
        let model = RecapCardModel.make(flight: MockFlights.ksqlKtvl, selection: .sharingDefaults)
        #expect(!model.visibleText.isEmpty)
        #expect(spy.renders == 0)
        #expect(session.renderCount == 0)

        #expect(session.imageForSave(access: .denied, using: spy) == nil)
        #expect(spy.renders == 0)
        #expect(session.renderCount == 0)

        #expect(session.share(using: spy) != nil)
        #expect(spy.renders == 1)
        #expect(session.renderCount == 1)

        #expect(session.imageForSave(access: .granted, using: spy) != nil)
        #expect(spy.renders == 2)
        #expect(session.renderCount == 2)
    }

    @Test func silhouetteNeedsTwoPoints() {
        let start = TrackPoint(latitude: 37, longitude: -122, altitudeFeet: nil, timestamp: nil)
        let end = TrackPoint(latitude: 38, longitude: -121, altitudeFeet: nil, timestamp: nil)
        let line = RouteSilhouette.path(points: [start, end], in: CGSize(width: 200, height: 120))
        #expect(!line.isEmpty)
        #expect(line.boundingRect.width > 1)
        #expect(line.boundingRect.height > 1)
        #expect(RouteSilhouette.path(points: [start], in: CGSize(width: 200, height: 120)).isEmpty)
        #expect(RouteSilhouette.path(points: [], in: CGSize(width: 200, height: 120)).isEmpty)
    }
}

private final class RecapRendererSpy: RecapImageRendering {
    var renders = 0

    func renderImage() -> UIImage? {
        renders += 1
        return UIImage()
    }
}
