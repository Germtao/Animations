//
//  CharacterLabel.swift
//  SecretTextAnimation
//
//  Created by QDSG on 2021/2/23.
//

import UIKit
import QuartzCore
import CoreText

class CharacterLabel: UILabel {
    let textStorage = NSTextStorage(string: " ")
    let textContainer = NSTextContainer()
    let layoutManager = NSLayoutManager()
    
    var oldCharacterTextLayers = [CATextLayer]()
    var characterTextLayers = [CATextLayer]()
    
    override var lineBreakMode: NSLineBreakMode {
        get { super.lineBreakMode }
        set {
            textContainer.lineBreakMode = newValue
            super.lineBreakMode = newValue
        }
    }
    
    override var numberOfLines: Int {
        get { super.numberOfLines }
        set {
            textContainer.maximumNumberOfLines = newValue
            super.numberOfLines = newValue
        }
    }
    
    override var bounds: CGRect {
        get { super.bounds }
        set {
            textContainer.size = newValue.size
            super.bounds = newValue
        }
    }
    
    override var text: String! {
        get { super.text }
        set {
            let wordRange = NSMakeRange(0, newValue.count)
            let attributedText = NSMutableAttributedString(string: newValue)
            let style = NSMutableParagraphStyle()
            style.alignment = textAlignment
            
            let attributes = [
                NSAttributedString.Key.foregroundColor: textColor,
                NSAttributedString.Key.font: font,
                NSAttributedString.Key.paragraphStyle: style
            ]
            
            attributedText.addAttributes(attributes as [NSAttributedString.Key : Any], range: wordRange)
            
            self.attributedText = attributedText
        }
    }
    
    override var attributedText: NSAttributedString? {
        get { super.attributedText }
        set {
            if textStorage.string == newValue?.string { return }
            
            cleanOutOldCharacterTextLayers()
            oldCharacterTextLayers = [CATextLayer](characterTextLayers)
            textStorage.setAttributedString(newValue!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayoutManager()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayoutManager()
    }
}

extension CharacterLabel {
    private func setupLayoutManager() {
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        textContainer.size = bounds.size
        textContainer.maximumNumberOfLines = numberOfLines
        textContainer.lineBreakMode = lineBreakMode
        layoutManager.delegate = self
    }
    
    private func cleanOutOldCharacterTextLayers() {
        for textLayer in oldCharacterTextLayers {
            textLayer.removeFromSuperlayer()
        }
        oldCharacterTextLayers.removeAll(keepingCapacity: false)
    }
    
    func initialTextLayerAttributes(_ textLayer: CATextLayer) {
        
    }
    
    private func internalAttributedText() -> NSMutableAttributedString {
        let wordRange = NSMakeRange(0, textStorage.string.count)
        let attributedText = NSMutableAttributedString(string: textStorage.string)
        attributedText.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor.cgColor, range: wordRange)
        attributedText.addAttribute(NSAttributedString.Key.font, value: font as Any, range: wordRange)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = textAlignment
        
        attributedText.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: wordRange)
        
        return attributedText
    }
    
    private func calculateTextLayers() {
        characterTextLayers.removeAll(keepingCapacity: false)
        
        let attributedText = textStorage.string
        
        let wordRange = NSMakeRange(0, attributedText.count)
        let attributedString = internalAttributedText()
        let layoutRect = layoutManager.usedRect(for: textContainer)
        
        var index = wordRange.location
        
        while index < wordRange.length + wordRange.location {
            let glyphRange = NSMakeRange(index, 1)
            let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
            let textContainer = layoutManager.textContainer(forGlyphAt: index, effectiveRange: nil)
            var glyphRect = layoutManager.boundingRect(forGlyphRange: glyphRange, in: textContainer!)
            let location = layoutManager.location(forGlyphAt: index)
            let kerningRange = layoutManager.range(ofNominallySpacedGlyphsContaining: index)
            
            if kerningRange.length > 1 && kerningRange.location == index {
                if characterTextLayers.count > 0 {
                    let previousLayer = characterTextLayers[characterTextLayers.endIndex - 1]
                    var frame = previousLayer.frame
                    frame.size.width += glyphRect.maxX - frame.maxX
                    previousLayer.frame = frame
                }
            }
            
            glyphRect.origin.y += location.y - (glyphRect.height - bounds.height + layoutRect.height) / 2
            
            let textLayer = CATextLayer(frame: glyphRect, attributeString: attributedString.attributedSubstring(from: characterRange))
            initialTextLayerAttributes(textLayer)
            
            layer.addSublayer(textLayer)
            characterTextLayers.append(textLayer)
            index += characterRange.length
        }
    }
}

extension CharacterLabel: NSLayoutManagerDelegate {
    func layoutManager(_ layoutManager: NSLayoutManager, didCompleteLayoutFor textContainer: NSTextContainer?, atEnd layoutFinishedFlag: Bool) {
        calculateTextLayers()
    }
}
