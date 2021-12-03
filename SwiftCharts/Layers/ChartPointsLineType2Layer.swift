//
//  ChartPointsLineLayer.swift
//  SwiftCharts
//
//  Created by ischuetz on 25/04/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit



open class ChartPointsLineType2Layer<T: ChartPoint>: ChartPointsLayer<T> {
    open fileprivate(set) var lineModels: [ChartLineModel<T>]
    open fileprivate(set) var lineViews: [ChartLinesView] = []
    public let pathGenerator: ChartLinesViewPathGenerator
    open fileprivate(set) var screenLines: [(screenLine: ScreenLine<T>, view: ChartLinesView)] = []
    
    public let useView: Bool
    public let delayInit: Bool
    
    fileprivate var isInTransform = false
    
    public init(xAxis: ChartAxis, yAxis: ChartAxis, lineModels: [ChartLineModel<T>], pathGenerator: ChartLinesViewPathGenerator = StraightLinePathType2Generator(), displayDelay: Float = 0, useView: Bool = true, delayInit: Bool = false) {
        self.lineModels = lineModels
        self.pathGenerator = pathGenerator
        self.useView = useView
        self.delayInit = delayInit
        
        let chartPoints: [T] = lineModels.flatMap{$0.chartPoints}
        
        super.init(xAxis: xAxis, yAxis: yAxis, chartPoints: chartPoints, displayDelay: displayDelay)
    }
    
    fileprivate func toScreenLine(lineModel: ChartLineModel<T>, chart: Chart) -> ScreenLine<T> {

        return ScreenLine(
            points: lineModel.chartPoints.map{chartPointScreenLoc($0)},
            colors: lineModel.lineColors,
            lineWidth: lineModel.lineWidth,
            lineJoin: lineModel.lineJoin,
            lineCap: lineModel.lineCap,
            animDuration: lineModel.animDuration,
            animDelay: lineModel.animDelay,
            lineModel: lineModel,
            dashPattern: lineModel.dashPattern
        )
    }
    
    override open func display(chart: Chart) {
        if !delayInit {
            if useView {
                initScreenLines(chart)
            }
        }
    }
    
    open func initScreenLines(_ chart: Chart) {
        let screenLines = lineModels.map{toScreenLine(lineModel: $0, chart: chart)}
        
        for screenLine in screenLines {
            let lineView = generateLineView(screenLine, chart: chart)
            lineViews.append(lineView)
            lineView.isUserInteractionEnabled = false
            chart.addSubviewNoTransform(lineView)
            self.screenLines.append((screenLine, lineView))
        }
    }
    
    open func generateLineView(_ screenLine: ScreenLine<T>, chart: Chart) -> ChartLinesView {
        return ChartLinesView(
            path: pathGenerator.generatePath(points: screenLine.points, lineWidth: screenLine.lineWidth),
            frame: chart.contentView.bounds,
            lineColors: screenLine.colors,
            lineWidth: screenLine.lineWidth,
            lineJoin: screenLine.lineJoin,
            lineCap: screenLine.lineCap,
            animDuration: isInTransform ? 0 : screenLine.animDuration,
            animDelay: isInTransform ? 0 : screenLine.animDelay,
            dashPattern: screenLine.dashPattern
        )
    }
    
    override open func chartDrawersContentViewDrawing(context: CGContext, chart: Chart, view: UIView) {
        if !useView {
            for lineModel in lineModels {
                let points = lineModel.chartPoints.map { modelLocToScreenLoc(x: $0.x.scalar, y: $0.y.scalar) }
                let path = pathGenerator.generatePath(points: points, lineWidth: lineModel.lineWidth)
                
                context.saveGState()
                context.addPath(path.cgPath)
                context.setLineWidth(lineModel.lineWidth)
                context.setLineJoin(lineModel.lineJoin.CGValue)
                context.setLineCap(lineModel.lineCap.CGValue)
                context.setLineDash(phase: 0, lengths: lineModel.dashPattern?.map { CGFloat($0) } ?? [])
                context.setStrokeColor(lineModel.lineColors.first?.cgColor ?? UIColor.white.cgColor)
                context.strokePath()
                context.restoreGState()
            }
        }
    }
    
    open override func modelLocToScreenLoc(x: Double) -> CGFloat {
        return xAxis.screenLocForScalar(x) - (chart?.containerFrame.origin.x ?? 0)
    }
    
    open override func modelLocToScreenLoc(y: Double) -> CGFloat {
        return yAxis.screenLocForScalar(y) - (chart?.containerFrame.origin.y ?? 0)
    }
    
    open override func zoom(_ scaleX: CGFloat, scaleY: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        }
    }
    
    open override func zoom(_ x: CGFloat, y: CGFloat, centerX: CGFloat, centerY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }
    
    open override func pan(_ deltaX: CGFloat, deltaY: CGFloat) {
        if !useView {
            chart?.drawersContentView.setNeedsDisplay()
        } else {
            updateScreenLines()
        }
    }

    fileprivate func updateScreenLines() {

        guard let chart = chart else {return}
        
        isInTransform = true
        
        for i in 0..<screenLines.count {
            for j in 0..<screenLines[i].screenLine.points.count {
                let chartPoint = screenLines[i].screenLine.lineModel.chartPoints[j]
                screenLines[i].screenLine.points[j] = modelLocToScreenLoc(x: chartPoint.x.scalar, y: chartPoint.y.scalar)
            }
            
            screenLines[i].view.removeFromSuperview()
            screenLines[i].view = generateLineView(screenLines[i].screenLine, chart: chart)
            chart.addSubviewNoTransform(screenLines[i].view)
        }
        
        isInTransform = false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineJoin(_ input: CAShapeLayerLineJoin) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromCAShapeLayerLineCap(_ input: CAShapeLayerLineCap) -> String {
	return input.rawValue
}
