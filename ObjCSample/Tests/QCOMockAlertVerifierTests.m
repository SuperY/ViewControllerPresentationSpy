@import ViewControllerPresentationSpy;

#import "ViewController.h"

@import XCTest;

@interface QCOMockAlertVerifierTests : XCTestCase
@end

@implementation QCOMockAlertVerifierTests
{
    QCOMockAlertVerifier *sut;
    ViewController *vc;
}

- (void)setUp
{
    [super setUp];
    sut = [[QCOMockAlertVerifier alloc] init];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    vc = [storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ViewController class])];
    [vc loadViewIfNeeded];
}

- (void)tearDown
{
    sut = nil;
    vc = nil;
    [super tearDown];
}

- (void)showAlert
{
    [vc.showAlertButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

- (void)test_executeActionForButtonWithTitle_withNonexistentTitle_shouldReturnError
{
    [self showAlert];

    NSError *error = nil;
    [sut executeActionForButtonWithTitle:@"NO SUCH BUTTON" andReturnError:&error];

    XCTAssertNotNil(error);
    XCTAssertEqual(error.code, 0); // buttonNotFound
    XCTAssertEqualObjects(error.domain, @"ViewControllerPresentationSpy.AlertVerifierErrors");
}

- (void)test_executeActionForButtonWithTitle_withoutHandler_shouldNotCrash
{
    [self showAlert];

    NSError *error = nil;
    [sut executeActionForButtonWithTitle:@"No Handler" andReturnError:&error];

    XCTAssertNil(error);
}

- (void)test_presentingNonAlertViewController_shouldNotTriggerVerifier
{
    [vc presentNonAlert];

    XCTAssertEqual(sut.presentedCount, 0);
}

- (void)test_showingAlert_shouldExecuteCompletionBlock
{
    __block int completionCallCount = 0;
    sut.completion = ^{
        completionCallCount += 1;
    };
    
    [self showAlert];
    
    XCTAssertEqual(completionCallCount, 1);
}

- (void)test_notShowingAlert_shouldNotExecuteCompletionBlock
{
    __block int completionCallCount = 0;
    sut.completion = ^{
        completionCallCount += 1;
    };
    
    XCTAssertEqual(completionCallCount, 0);
}

@end
