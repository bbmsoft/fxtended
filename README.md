# FXtended

FXtended is library heavily inspired by [Sven Efftinge](https://github.com/svenefftinge)'s [XtendFX](https://github.com/svenefftinge/xtendfx).

Just like XtendFX it aims at making JavaFX programming with Xtend a joy by providing many useful active annotations and extension methods.

Here are some of the most important:

## @BindableProperty

This active annotation turns a field into a JavaFX property, including getter, setter and property getter. This works for fields of any type. The behavior of the property can further be specified with additional annotations:

```xtend
class MyClass {

	@BindableProperty String name			// creates an eagerly initialized SimpleStringProperty
	
	@ReadOnly @BindableProperty double size	= 2.0	// creates a SimpleDoubleProperty and an according ReadOnlyDoubleWrapper
							// with the inital value 2.0

	@Lazy @BindableProperty UUID uuid		// creates a lazily initialized SimpleObjectProperty&lt;UUID&gt;

	@CheckFXThread @BindableProperty long duration	// creates a SimpleLongProperty that throws an exception when modified
							// from any other than the JavaFX Application Thread

	@Styleable('-fx-my-custom-css-property')	// creates a styleable property that can be set from css and has the
	@BindableProperty Paint background = Color.RED	// inital value Color.RED (styleable properties must have initial values)
							// "MyClass { -fx-my-custom-css-property: black; }" will set it to Color.BLACK
}

```
There's more, but these are the most important ones.

## @FXMLRoot

Annotate your custom Parent class with this and Xtend will automatically load it from FXML. Here's an example:

```xtend
@FXMLRoot
class CustomPanel extends HBox {

	@FXML TextField textField
	@FXML Button button
}

```
This will automatically enhance CustomPanel's constructor to look for an FXML file called CustomPanel.fxml in CustomPanel's package, set CustomPanel as root and controller and load the FXML file. If your FXML file is in another package or has a different name you can annotate the class with @FXML('/path/to/fxml/Panel.fxml') instead.

## @PseudoClasses

Using a lot of pseudoclasses and tired of calling Pseudoclass.getPseudoClass('name') a million times? Just annotate your class with @PseudoClasses('name1', 'name2', 'name3') and Xtend will add 

```java
private static final PseudoClass PSEUDO_CLASS_NAME1 = PseudoClass.getPseudoClass('name1');
private static final PseudoClass PSEUDO_CLASS_NAME2 = PseudoClass.getPseudoClass('name2');
private static final PseudoClass PSEUDO_CLASS_NAME3 = PseudoClass.getPseudoClass('name3');

```
to it.

## Bindig Operators

There are a bunch of possibilities to simply bind properties or add listeners to them with simple operators. Here are just a few examples:

```propertyA << propertyB``` does propertyA.bind(propertyB)
```propertyA >> propertyB``` does propertyB.bind(propertyA)
```propertyA <> propertyB``` does propertyA.bindBidirectional(propertyB)


```propertyA >> [newValue | handle(newValue)]``` adds a ChangeListener to propertyA. Also the listener is immediately called with propertyA's current value.
```propertyA >> [observable, oldValue, newValue | handle(newValue)]``` adds a ChangeListener to propertyA. Also the listener is immediately called with propertyA's current value.


```propertyA > [handleChange]``` adds an InvalidationListener to propertyA


```#[propertyA, propertyB, propertyC, propertyD] > [handleChange]``` adds the same InvalidationListener to all four properties


```numberPropertyA + numberPropertyB``` creates a NumberBinding who's calue is the sum of numberPropertyA's and numberPropertyB's values
```numberPropertyA - numberPropertyB``` creates a NumberBinding who's calue is the difference of numberPropertyA's and numberPropertyB's values
```numberPropertyA * numberPropertyB``` ... I guess you get the point. It also works with ```numberPropertyA + 5```, ```booleanPropertyA && booleanPropertyB```, etc.

## Observable Collections

There are also some useful extension methods for observable collections. Here are a few more examples:

```observableList >> [added, removed | handleChanges(added, removed)]``` adds a ListChangeListener to observableList


```observableList.push(someOtherList)``` adds a ListChangeListener to observableList that applies all changes also to someOtherList


```observableList.push(myListView.items)[runLater]``` adds a ListChangeListener to observableList that applies all changes to the items of a listView on the JavaFX thread. Useful when the modification of observableList happens from a background thread but must be reflected in the UI


