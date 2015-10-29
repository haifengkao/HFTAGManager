# HFTAGManager

[![CI Status](http://img.shields.io/travis/Hai Feng Kao/HFTAGManager.svg?style=flat)](https://travis-ci.org/Hai Feng Kao/HFTAGManager)
[![Version](https://img.shields.io/cocoapods/v/HFTAGManager.svg?style=flat)](http://cocoapods.org/pods/HFTAGManager)
[![License](https://img.shields.io/cocoapods/l/HFTAGManager.svg?style=flat)](http://cocoapods.org/pods/HFTAGManager)
[![Platform](https://img.shields.io/cocoapods/p/HFTAGManager.svg?style=flat)](http://cocoapods.org/pods/HFTAGManager)

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```objc
HFTAGRule* rule = [[HFTAGRule alloc] initWithBlock:^[(TagRule* rule){
    NSPredicate *purchased = [NSPredicate predicateWithFormat:@"SELF.isPurchased MATCHES %@", @"1"];
    [rule setPredicate:purchased rule:@{@"gift":@"apple"}];

    // not purchased
    [rule setPredicate:nil rule:@{@"gift":@"nothing"}];
}];
NSDictionary* gift = [container dictionaryForKey:@"specialGift" defaultRule:rule];
```

## Requirements

## Installation

HFTAGManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "HFTAGManager"
```

## Author

Hai Feng Kao, haifeng@cocoaspice.in

## License

HFTAGManager is available under the MIT license. See the LICENSE file for more info.
