// https://github.com/Quick/Quick

import Quick
import Nimble
import FBSnapshotTestCase
import Nimble_Snapshots
import KIF_Quick
@testable import UIAnimatedSearchBar_Example

class ViewControllerSpec: KIFSpec
{
    override func spec()
    {
        var sut: AnimatedSearchBarViewController!
        
        beforeEach
            {
                //Setup for AnimatedSearchBarViewController from IB
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                sut = storyboard.instantiateViewController(withIdentifier: "BasicTestViewController") as! AnimatedSearchBarViewController
                UIApplication.shared.keyWindow!.rootViewController = sut
                let _ = sut.view
        }
        
        afterEach
            {
                sut = nil
        }
        
        describe("AnimatedSearchBarDelegate")
        {
            describe("Changing Text")
            {
                beforeEach {
                    tester().enterText("Test text", intoViewWithAccessibilityLabel: "searchTextField")
                }
                it("Did Change")
                {
                    expect(sut.searchBarTextDidChangeWasCalled).toEventually(be(true))
                }
                it("Calls shouldChangeTextIn")
                {
                    expect(sut.searchBarShouldChangeTextInWasCalled).toEventually(be(true))
                }
            }
            describe("Begin Editing")
            {
                beforeEach {
                    let _ = sut.animatedSearchBar.becomeFirstResponder()
                }
                it("ShouldBeginEditing function is called")
                {
                    expect(sut.searchBarShouldBeginEditingWasCalled).to(be(true))
                }
                it("DidBeginEditing function is called")
                {
                    expect(sut.searchBarDidBeginEditingWasCalled).toEventually(be(true))
                }
            }
            
            describe("End Editing")
            {
                
                beforeEach {
                    let _ = sut.animatedSearchBar.becomeFirstResponder()
                    Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block:
                        {
                            _ in
                            let _ = sut.animatedSearchBar.resignFirstResponder()
                    })
                }
                it("ShouldEndEditing function is called")
                {
                    expect(sut.searchBarShouldEndEditingWasCalled).toEventually(be(true))
                }
                it("DidEndEditing function is called")
                {
                    expect(sut.searchBarDidEndEditingWasCalled).toEventually(be(true))
                }
            }
            describe("Bookmark Button")
            {
                beforeEach
                    {
                        sut.animatedSearchBar.showBookmarkButton = true
                        sut.animatedSearchBar.bookmarkButton?.sendActions(for: UIControlEvents.touchUpInside)
                }
                it("Delegate callback")
                {
                    expect(sut.searchBarBookmarkButtonClickedWasCalled).toEventually(be(true))
                }
            }
            describe("Cancel Button")
            {
                beforeEach
                    {
                        sut.animatedSearchBar.showsCancelButton = true
                        sut.animatedSearchBar.cancelButton?.sendActions(for: UIControlEvents.touchUpInside)
                }
                it("Delegate callback")
                {
                    expect(sut.searchBarCancelButtonClickedWasCalled).toEventually(be(true))
                }
            }
            describe("Search Button")
            {
                beforeEach
                    {
                        let _ = sut.animatedSearchBar.becomeFirstResponder()
                        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block:
                            {
                                _ in
                            sut.animatedSearchBar.pressReturn()
                        })
                }
                it("Delegate callback")
                {
                    expect(sut.searchBarSearchButtonClickedWasCalled).toEventually(be(true))
                }
            }
        }
        
        describe("Customization")
        {

            it("Cancel button shows")
            {
                sut.animatedSearchBar.showsCancelButton = true
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
            
            it("Bookmark button shows")
            {
                sut.animatedSearchBar.showBookmarkButton = true
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
            it("tintColor works")
            {
                sut.animatedSearchBar.tintColor = .orange
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
            it("barTintColor works")
            {
                sut.animatedSearchBar.barTintColor = .blue
                sut.animatedSearchBar.tintColor = .orange
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
            it("backgroundColor works")
            {
                sut.animatedSearchBar.backgroundColor = .blue
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
            it("placeholder text works")
            {
                sut.animatedSearchBar.placeholder = "Sweet Placeholder Text"
//                expect(sut.animatedSearchBar).to(recordDeviceAgnosticSnapshot())
                expect(sut.animatedSearchBar).to(haveValidDeviceAgnosticSnapshot())
            }
        }
    }
}

