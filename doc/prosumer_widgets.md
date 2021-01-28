# Exploration

This is a working document for me to remind myself of the journey between my first attempt at a Flutter widget, and my road to understanding the challenges and learnings required to build the mythical _professional-grade_ widget. I believe this difference exists because I have looked at the open source code behind Flutter's own Material Design widgets. 

In fact, after developing my [initial version of a simple toggle widget](https://github.com/BlueCowGroup/thememode_selector/tree/v0.1.0), I have taken a peek at the code found in widgets like Slider, Checkbox, and Switch and I am left scratching my head. There is so much code there which I did not account for. Even the rendering of the widgets is done in an entirely different way than I did. Switch is over 1,000 lines of code while my component is less than four hundred. I wonder what use cases I don't account for or what critical functionality do I not support.

While I was developing, there were known areas I was short-cutting. I knew I shouldn't pass color parameters into my component; I should have used theming constructs. Adding new colors to the established ThemeData objects is a big topic, so I punted on that. Likewise, I am vaguely aware of the debug diagnostics method and I skirted that implementation as well. I also neglected support for semantic events, and I feel very strongly that every component I develop will have a high level of accessibility. More important however is identifying what functionality I don't know I should be supporting, and learning how I can begin to elevate my skills to the true pro level.

So, I see this as an opportunity to dissect some of the "official" packages and perform some deep dives to learn what I am missing. And this post is my means of documenting this to help myself in the future and other interested parties.

# Survey of what is missing

I have performed a line-by-line reading of several Material components that ship with Flutter, and here is the list of functionality I did not include.

* [**State management**](#state_management) - My component manages its own toggle state internally, while the prosumer components require the user to control the state of the value of the toggle. I found this difficult to understand as a user of Flutter widgets as well. Why can't a checkbox maintain its own true/false values. So, I am interested in learning why that's a best practice followed by the standard widgets.
* **Event callbacks** - the standard components emit more events. I was concerned with emitting an `onChanged()` event, while the built-in widgets emit.
* **[Theme support](#theme_support)** - This is a known area I need to beef up. Turns out there isn't an issue passing colors into my component, but in the absence of these optional parameters, I need to consult the ThemeData information to extract the appropriate color for my purposes. This is a bit of a problem in my case which I'll discuss in more detail in the section on themes.
* **States** - Material Design and Flutter's implementation has a whole subsystem for managing theme properties and how they respond to several states (e.g. disabled, focused, hovered, selected, and others). I don't have support for any of that.
* **Keyboard/Focus** - Yup, I totally ignored support for the keyboard and indicating focus concerns for web and iPadOS platforms.
* **Semantic events** - I mentioned this earlier. I have some experience on the web with accessibility but very little on mobile and none on Flutter.
* **Null-safety** - My prior language experience didn't have support for null-safety. I think I understand it well enough to implement, but just when I think I understand it, I can get thrown. Still a bit shaky on the `late` keyword and what the exclamation is for in `widget.onChanged!(true)`. Looking forward to implementing this in my code so I can understand it better overall.
* [**RenderObject**](#render) - It is very confusing for me to see these other components using a RenderObjectWidget in their implementations. I don't know if this will impact my implementation yet, but it will be interesting to learn why they just don't build out the widgets in (what I would consider being) the typical `build(BuildContext context)` manner. It seemed to work fine in my original component, but perhaps I am missing something?
* **Testing** - It goes without saying we need (close to) complete code coverage before a component can be considered ready for production

## What I got right

What I did well in my first attempt ... is not much. Other than creating a somewhat usable component, it is a hobbyist's effort. Any real enterprise using my component would run into limitations in accessibility, platform support (on the web especially), and integration into their theming mechanism. 

So the journey begins to learn more about the official and correct way to develop prosumer-grade widgets.

<a name="state_management"></a>

# State Management





<a name="theme_support"></a>

# Theme Support

At the beginning of 2020, the Flutter team began rethinking the way they managed theme data throughout the system. Their initial approach was showing its limitations and the ad hoc use of color and style was getting hard to maintain and use properly. A [new approach](https://docs.google.com/document/d/1kzIOQN4QYfVsc5lMZgy_A-FWGXBAJBMySGqZqsJytcE/edit?usp=sharing) to Flutter themeing was documented and efforts began to port the existing widgets. I'm not sure if all of the Material components are now using this approach, however, the ones I reviewed for this document are compliant.

Based on this document, we have some new best practices

* Widgets are responsible for defining their own Theme and ThemeData classes
* These new classes are typically contained in a separate file than their components
* The Theme is an Inherited widget that allows for discoverability by the widgets who will need their settings
* The settings maintained in the ThemeData will contain the colors, sizing, and mouse cursor
* Also included in the ThemeData are debug output, hashcode/equality checks and a lerp function

Well, this is great for the standard set of widgets as these new ThemeData objects are stored alongside all of the other ThemeData objects representing each of the built-in widgets. But how does a third-party component expose its own theming support in a manner that is built into Flutter's established theming mechanism?

## How do we utilize Theme and ThemeData

Generally, developers creating an app in Flutter will use the `Theme` class which houses methods to modify most of the style attributes in the form of a `ThemeData` class. When a developer creates their `MaterialApp` instance, they will (usually) start with the light or dark version of the standard Material theme, and they will override specific properties to make global changes to a component throughout the application.

`ThemeData` is the data structure which holds the various color schemes, text styles and size properties. `Theme` is a widget which acts as a holder of `ThemeData` for all descendants in the widget tree. These descendants can query the `Theme` class using the hierarchy lookup functionality to get a particular set of `ThemeData` properties.

When using a `MaterialApp`, the developer will specify a `theme` which is an instance of `ThemeData`. They can also choose to provide a `darkTheme` representing the dark mode theme data. Behind the scenes, the `MaterialApp` will create an `AnimatedTheme` class and choose which set of theme data should be associated with the application based on the `ThemeMode` set on the application and the optional presence of a `darkTheme`.

So, getting back to the purpose of this section. If I create my own set of `ThemeData` for my new custom component, how can the developer using my component use the `Theme` to style it? Unfortunately, the Theming API doesn't allow ad hoc components to be added to it. This is a key side effect of the declarative nature of FLutter, resulting in all style attributes available for use in the `ThemeData` class only contains those widgets that are part of the standard Material widgets that ship with Flutter. There is no way for us to introduce our custom `ThemeData` into the Material `Theme` class.

Instead, we are expected to provide our own `MyTheme` widget and `MyThemeData` class, and the developer is responsible for wrapping their widget tree with our class. This may also result in an unruly nesting of theme data classes for each collection of widgets or for each individual new widget you choose. 

Let's begin with a simplistic widget and the custom theme class we might expose to style it.

> **NOTE**
> This is a very overly simplified example of using a theme for a couple color properties and a border width, and it does not take component states into consideration. Things will get a lot more complicated before we are through with our theming. We will cover component states in another section of this deep dive, but for now, let's pick apart this example.

```dart
class ThemeModeSelectorTheme extends InheritedWidget {
  final ThemeModeSelectorThemeData data;

  const ThemeModeSelectorTheme({Key key, this.data, Widget child})
      : super(key: key, child: child);

  static ThemeModeSelectorThemeData of(BuildContext context) {
    var theme =
        context.dependOnInheritedWidgetOfExactType<ThemeModeSelectorTheme>();
    return theme.data ?? ThemeModeSelectorThemeData();
  }

  @override
  bool updateShouldNotify(ThemeModeSelectorTheme oldWidget) {
    return oldWidget.data == data;
  }
}

class ThemeModeSelectorThemeData with Diagnosticable {
  final Color lightToggleColor;
  final Color lightBackgroundColor;
  final Color darkToggleColor;
  final Color darkBackgroundColor;
  final double height;

  ThemeModeSelectorThemeData({
    this.lightToggleColor,
    this.lightBackgroundColor,
    this.darkToggleColor,
    this.darkBackgroundColor,
    this.height,
  });
}
```

Given this component and approach to theming, there are three ways to style the attributed I have exposed on my circle widget.

1. Use the style passed to the `MyCircle` instance as a constructor parameter

2. Use a style specified in the `MyCircleTheme` which can be set at any level in the widget hierarchy

3. Rely on a style setting hardcoded as the default value in the `MyCircle` widget

   > Note: While the style is hardcoded in the widget, it is often based on a style that appears in the root `ThemeData` instance used by the `MaterialApp` as I demonstrate in this example

As you can see, there are a few different ways to style the component, and the order above is the order of precedence on how the final style is chosen.

Let's take a look at how this looks in a usage example.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      home: MyCircleTheme(
        data: MyCircleThemeData(
          foregroundColor: Colors.orange,
          borderColor: Colors.orange[900],
        ),
        child: MyHomePage(),
      ),
    );
  }
}
```

This usage example shows how the `MyCircleTheme` widget is added to the widget tree and shades of orange are used to style the `MyCircle` widget. Overall, this is pretty straightforward, but also a bit unwieldy. You can imagine what this might look like if you are leveraging the custom components of several different widgets each with its own `ThemeData` class. That's a lot of nesting of widgets, and this is a common "problem" with Flutter's declarative approach to UX. In practice, you will probably create an app-specific widget where you nest all the entire `ThemeData` hierachy into a single component. 

No matter how you choose to make the code less messy, you can see the additional methods which are needed to make our `ThemeData` more performant. A ThemeData class should have the following characteristics.

1. `ThemeData` implementations are immutable by practice. This requires us to provide a method (e.g. `copyWith(…)`) that allows a developer to replace one or more of our style attributes without having to provide _all_ of the attributes
2. Our class is a `const` and we have to provide an equality check and hashcode method.
3. It is also responsible for us to implement proper Diagnostics for debug logging

> **NOTE** 
> I'm a bit surprised the default values for our custom `ThemeData` classes are not encapsulated in the `ThemeData` class itself. I suspect this would be the reasonable place to put default values, however much of the time the colors we choose to be default colors for our components will be based on the color scheme of the root `Theme` for the application. Getting access to this root `Theme` object is accomplished using the `InheritedWidget` approach which means we need a `BuildContext` to perform the lookup, and a `context` is not available in our custom `ThemeData` class.

## The Animation Problem

There is nothing inherently *wrong* with `ThemeData`, but while the approach is meant to establish a best practice, it does not play nice with Flutter's awesome built-in animation as theme's change. I guess I should say that our custom `ThemeData` instances do not play well with Flutter's `AnimatedTheme` widget, while all of Flutter's built-in `ThemeData` classes work just fine. This breakdown occurs because the root `ThemeData` class knows full well about Flutter's widgets and their theming constructs, but doesn't know shit about ours.

> @todo: is this true? can extensions enable our custom theme data to be lerped alongside the standard attributes, or perhaps the animationController is exposed so we can use it?
>
> @todo: still need to close the story on why we implement `lerp` and how we support (or don't support) animation



<a name="render"></a>

# Rendering the Widget

Buckle up, because this section runs deep. To research what it takes to render a Prosumer widget, I have looked hard at the `Switch` widget and the `CheckBox` widget. Both of these widgets provide their own `RenderObjectWidget` which in turn creates a deep set of classes culminating in a  `RenderBox`  in the bowels of the Flutter framework. 

Why, oh why do we not simply use our `StatefulWidgets`'  `build(BuildContext context)` method to lay out our widgets like we would any normal UX. Why are we delving into so much obscure code to paint a pretty simple widget. No seriously, I'm asking why?

![checkbox_uml](https://raw.githubusercontent.com/BlueCowGroup/thememode_selector/main/doc/images/checkbox_uml.svg)

Obviously we don't have to implement all of these classes. The ones which we are responsible for are as follows.

* `Checkbox`
  The topmost widget implemented as a `StatefulWidget`. It creates the `_CheckboxState ` class. This class exists primarily as a holding place for the widget's public API. This class is immutable and all of the properties are typically declared as final. This class itself does not manage any stateful properties, and if any of the properties change, a new instance of this class is created.
* `_CheckboxState`
  This class does manage the internal state of the widget, but also resolves material states and determines the appropriate theming styles based on these states. This also results in keyboard mapping and focusable control for those platforms that require it. Ultimately, almost all of the physical rendering is delegated to the `_CheckboxRenderObjectWidget`.
* `_CheckboxRenderObjectWidget`
  This widget primarily exists to create the `_RenderCheckbox` but every style property, state property (including Material States) and even animation have to be passed along from the `_CheckboxState`to this class and onto the `_RenderCheckbox`. This class extends `LeafRenderObjectWidget`because it will have to `child` property.
* `_RenderCheckbox`
  This is where the drawing actually happens. The `paint()` method is responsible for drawing the checkbox outline, the checkmark is `value` is true and a dash if `value` is null. A lot of functionality is inherited from `RenderToggleable` and if you are writing a toggle (as we are in `ThemeModeSelector`) you have to know it fairly well.

## What is the purpose behind `RenderObjectWidget`?

> **Note** 
>
> Research for this section consists of the following readings
>
> * [Inside Flutter](https://flutter.dev/docs/resources/inside-flutter) by the Flutter team
> * [Demystifying Widgets and RenderObjects Myths](https://medium.com/code-to-express/demystifying-widgets-and-renderobjects-myths-bdb19c070676) by Heritage Samuel Falodun
> * [Flutter, what are Widgets, RenderObjects and Elements?](https://medium.com/flutter-community/flutter-what-are-widgets-renderobjects-and-elements-630a57d05208) by Norbert

I have previously read the Flutter articles on how there are three trees maintained by Flutter and I vaguely recall that the trees at different levels are either immutable or have the potential for reuse with new values aka updating. I'm going to refresh myself and take some notes, but as I approach this subject, I still have a nagging doubt that this research will actually answer my question -- When (or Why) should I choose to use RenderObjectWidget, instead of composition right in my widget?

The Inside Flutter article uses some elite CS-speak to describe how the platform is carefully designed to support a declarative UX and high-performance UX based on its careful choices regarding the data structures used and algorithms surrounding reuse (of elements) and size/layout negotiation. A key factor in the performance of Flutter is ensuring that as little as possible of the render tree has to be recomputed or redrawn in response to a change in style or structure. 

#### Widget Tree

Widgets are classes that represent configuration information for a visual object. They form the API that developers utilize when creating a visual component and they are lightweight and immutable.

> An optimization mentioned in the "Inside Flutter" article involves the use of InheritedWidget. From the developers perspective it might be understood that a call to look up the current Theme might be walking back up the widget tree to find an ancestor of type Theme.
>
> `var themeData = Theme.of(context);`
>
> In order to keep performance high, objects extending from `InheritedWidget` are actively pushed down the tree and available to all child widgets. This is a clever optimization to keep the render passes fast.

#### Element Tree

The element tree is a data structure retaining the logical structure of the user interface. While the widgets themselves are immutable, the elements in this tree are a concrete representation of the component as it exists in the drawing context and its properties are mutable. Each Element holds a reference to its RenderObject and if the associated widget is a StatefulWidget, the Element will also hold the State objects.

The resuability of an Element is a key to Flutter's performance, and in many cases the layout calculations performed for the Element can be reused even if the state has changed. `GlobalKey` is used to establish a strong relationship between the widget and its element, and results in layout optimizations even if the objects moves to different locations in the element tree.

Each element maintains its own dirty state. This can be a reaction to external stimuli or by a call by the widget to `setState(...)`. During the build phase, the framework uses this dirty state indicator to identify the parts of the element tree which must be recalculated.

#### Render Tree

The render tree is a data structure which stores the geometry of the user interface. This structure enables the protocol that determines how components work with each other in the hierarchy to negotiate their dimensions and position based on rules surrounding constraints and size.

There is mention in "Inside Flutter" which might hint at my original question. When performing animations, changes in values notify an observer list. The render tree maintains a list of these observable objects so a change to an animation's value may trigger a paint change (in the RenderObject) without triggering both a build and paint.

The Element will create a RenderObject which handles the size, layout and painting of the component. 

### What are the Takeaways?

So, back to my original query. At what point should we use a RenderObjectWidget (and a RenderObject) versus using simple composition in our StatefulWidget?

> @todo: Still formulating the takeaway; question asked on the Google group (https://groups.google.com/g/flutter-dev/c/9x9Ke0wFzTs)

