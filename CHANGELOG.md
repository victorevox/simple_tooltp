## [1.2.0] - 07/09/22
* Updated for flutter 3.0.5

## [1.0.0] - 08/08/21.

* Merged https://github.com/victorevox/simple_tooltp/pull/25
* Null safety
* Feature, custom arrow offset
  
## [0.1.16] - 04/11/20.

* Fixed performance issues https://github.com/victorevox/simple_tooltp/issues/17 

## [0.1.15] - 04/11/20.

* Disabled onClose callback, as not implemented for the time being
* Merge pull request #19 from denisbabineau/master
    
    add horizontal / vertical TooltipDirection

## [0.1.14] - 05/08/20.

* Bug fixes - 
    ```
    Failed assertion: line 1705 pos 18: 'debugDoingThisResize
    flutter: || debugDoingThisLayout ||
    flutter:                  (RenderObject.debugActiveLayout == parent && _size._canBeUsedByParent)': is not
    flutter: true.
    ```

## [0.1.13] - 17/07/20.

* Bug fixes - Render box not attached error

## [0.1.12] - 9/07/20.

* Small change

## [0.1.11] - 9/07/20.

* Added `ObfuscateTooltipItem` widget, it allows for a tooltip to automatically hide when a `ObfuscateTooltipItem` widget it's inside tooltip's boundings, useful for autohide on Dialogs or Stacks. For more detail look at the new *Obfucaste* example;

## [0.1.10] - 8/06/20.

* Some fixes on implementation of route aware logic

## [0.1.9] - 8/06/20.

* New [routeObserver] property, widget will listen for route transition and will hide tooltip when the widget's route is not active

## [0.1.8] - 9/05/20.

* Fix minWidth doesn't work and throws errors https://github.com/victorevox/simple_tooltp/issues/3

## [0.1.7] - 9/05/20.

* Added animation when dismissing https://github.com/victorevox/simple_tooltp/issues/6
* Fix borderWidth=0 not honoured https://github.com/victorevox/simple_tooltp/issues/7
* Added [hideOnTooltipTap] capability, requested https://github.com/victorevox/simple_tooltp/issues/5
* Updated README
* Other fixes

## [0.1.6] - 9/05/20.

* Ensure tooltip is hidden when dispossing (fix: https://github.com/victorevox/simple_tooltp/issues/9)
* Merged https://github.com/victorevox/simple_tooltp/pull/10 (Thanks @rgb1380)

## [0.1.5] - 28/04/20.

* Fix issue where not setting tooltip offset correctly at first build round

## [0.1.4] - 28/04/20.

* Fix tooltip not handling "tap" events in specific scenarios

## [0.1.3] - 11/02/20.

* Minor Fixes

## [0.1.2] - 11/02/20.

* Fix `clipBehavior: Clip.none,` error

## [0.1.1] - 10/02/20.

* Updated README

## [0.1.0] - 10/02/20.

* First release.


## [0.0.1] - TODO: Add release date.

* TODO: Describe initial release.
