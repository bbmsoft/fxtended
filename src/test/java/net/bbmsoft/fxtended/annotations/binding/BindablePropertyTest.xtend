package net.bbmsoft.fxtended.annotations.binding

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

class BindablePropertyTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(BindableProperty.classLoader)

	@Test
	def void testFXBeanDefaultEmptyString() {

		val input = '''
			import java.util.List;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			
			class Item {
				
				 int nonBindable
				 
				 @BindableProperty String name
			}
		'''

		val output = '''
			import javafx.beans.property.StringProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  private int nonBindable;
			  
			  @BindableProperty
			  private final StringProperty _nameProperty = new javafx.beans.property.SimpleStringProperty(this, "name");
			  
			  public final String getName() {
			    return _nameProperty.get();
			  }
			  
			  public final void setName(final String value) {
			    _nameProperty.set(value);
			  }
			  
			  public final StringProperty nameProperty() {
			    return _nameProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}

	@Test
	def void testFXBeanDefaultEmptyDouble() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			
			class Item {
				
				 int nonBindable
				 
				 @BindableProperty double name
			}
		'''

		val output = '''
			import javafx.beans.property.DoubleProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  private int nonBindable;
			  
			  @BindableProperty
			  private final DoubleProperty _nameProperty = new javafx.beans.property.SimpleDoubleProperty(this, "name");
			  
			  public final double getName() {
			    return _nameProperty.get();
			  }
			  
			  public final void setName(final double value) {
			    _nameProperty.set(value);
			  }
			  
			  public final DoubleProperty nameProperty() {
			    return _nameProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
	@Test
	def void testFXBeanObjectProperty() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import java.net.URL
			
			class Item {
				
				 URL nonBindable
				 
				 @BindableProperty URL bindableURL
			}
		'''

		val output = '''
			import java.net.URL;
			import javafx.beans.property.ObjectProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  private URL nonBindable;
			  
			  @BindableProperty
			  private final ObjectProperty<URL> _bindableURLProperty = new javafx.beans.property.SimpleObjectProperty<java.net.URL>(this, "bindableURL");
			  
			  public final URL getBindableURL() {
			    return _bindableURLProperty.get();
			  }
			  
			  public final void setBindableURL(final URL value) {
			    _bindableURLProperty.set(value);
			  }
			  
			  public final ObjectProperty<URL> bindableURLProperty() {
			    return _bindableURLProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}

	@Test
	def void testFXBeanDefaultValue() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			
			class Item {
			  @BindableProperty String name = "John"
			}
		'''

		val output = '''
			import javafx.beans.property.StringProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  @BindableProperty
			  private final StringProperty _nameProperty = new javafx.beans.property.SimpleStringProperty(this, "name", "John");
			  
			  public final String getName() {
			    return _nameProperty.get();
			  }
			  
			  public final void setName(final String value) {
			    _nameProperty.set(value);
			  }
			  
			  public final StringProperty nameProperty() {
			    return _nameProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}

	@Test
	def void testFXBeanLazyEmpty() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Lazy
			
			class Item {
			  @Lazy @BindableProperty String name
			}
		'''

		val output = '''
			import javafx.beans.property.StringProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  private String _name = null;
			  
			  @BindableProperty
			  private StringProperty _nameProperty;
			  
			  public final String getName() {
			    if(_nameProperty == null) {
			      return _name;
			    } else {
			      return this._nameProperty.get();
			    }
			  }
			  
			  public final void setName(final String value) {
			    if(_nameProperty == null) {
			      _name = value;
			    } else {
			      this._nameProperty.set(value);
			    }
			  }
			  
			  public final StringProperty nameProperty() {
			    if(_nameProperty == null) {
			      _nameProperty = new javafx.beans.property.SimpleStringProperty(_name);
			    }
			    return _nameProperty;
			  }
			}
		'''
		
		input.assertCompilesTo(output)
	}

	@Test
	def void testFXBeanLazyValue() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Lazy
			
			class Item {
			  @Lazy @BindableProperty String name = "John"
			}
		'''

		val output = '''
			import javafx.beans.property.StringProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item {
			  private String _name = "John";
			  
			  @BindableProperty
			  private StringProperty _nameProperty;
			  
			  public final String getName() {
			    if(_nameProperty == null) {
			      return _name;
			    } else {
			      return this._nameProperty.get();
			    }
			  }
			  
			  public final void setName(final String value) {
			    if(_nameProperty == null) {
			      _name = value;
			    } else {
			      this._nameProperty.set(value);
			    }
			  }
			  
			  public final StringProperty nameProperty() {
			    if(_nameProperty == null) {
			      _nameProperty = new javafx.beans.property.SimpleStringProperty(_name);
			    }
			    return _nameProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
	@Test
	def void testFXBeanNonControlStyleable() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Styleable
			import javafx.scene.layout.Pane
			
			class Item extends Pane {
				
				 int nonBindable
				 
				 @Styleable("-something") @BindableProperty double something = 0.0
			}
		'''

		val output = '''
			import java.util.List;
			import javafx.css.CssMetaData;
			import javafx.css.Styleable;
			import javafx.css.StyleableDoubleProperty;
			import javafx.scene.layout.Pane;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item extends Pane {
			  private int nonBindable;
			  
			  @BindableProperty
			  private final StyleableDoubleProperty _somethingProperty = new javafx.css.SimpleStyleableDoubleProperty(SOMETHING, this, "something", 0.0);
			  
			  public final double getSomething() {
			    return _somethingProperty.get();
			  }
			  
			  public final void setSomething(final double value) {
			    _somethingProperty.set(value);
			  }
			  
			  public final StyleableDoubleProperty somethingProperty() {
			    return _somethingProperty;
			  }
			  
			  private final static CssMetaData<Item, Number> SOMETHING = new javafx.css.CssMetaData<Item, java.lang.Number>(
			    "-something", javafx.css.StyleConverter.getSizeConverter(), 0.0) {
			    
			      @Override
			      public boolean isSettable(Item styleable) {
			        return styleable._somethingProperty == null || !styleable._somethingProperty.isBound();
			      }
			    
			      @Override
			      public javafx.css.StyleableProperty<java.lang.Number> getStyleableProperty(Item styleable) {
			        return styleable.somethingProperty();
			      }
			    }
			    ;
			  
			  private static List<CssMetaData<? extends Styleable, ?>> cssMetaDataList;
			  
			  private final static Boolean cssInitialized = initializeCss();
			  
			  private static final Boolean initializeCss() {
			    java.util.List<javafx.css.CssMetaData<? extends javafx.css.Styleable, ? extends java.lang.Object>> temp = com.google.common.collect.Lists.newArrayList(Pane.getClassCssMetaData());
			    temp.add(SOMETHING);
			    cssMetaDataList = java.util.Collections.unmodifiableList(temp);
			    return true;
			  }
			  
			  public static List<CssMetaData<? extends Styleable, ?>> getClassCssMetaData() {
			    return cssMetaDataList;
			  }
			  
			  public List<CssMetaData<? extends Styleable, ?>> getCssMetaData() {
			    return getClassCssMetaData();
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
	@Test
	def void testFXBeanMultipleNonControlStyleable() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Styleable
			import javafx.scene.layout.Pane
			
			class Item extends Pane {
				
				 int nonBindable
				 
				 @Styleable("-something") @BindableProperty double something = 0.0
				 
				 @Styleable("-something-else") @BindableProperty String somethingElse = "yolo"
			}
		'''

		val output = '''
			import java.util.List;
			import javafx.css.CssMetaData;
			import javafx.css.Styleable;
			import javafx.css.StyleableDoubleProperty;
			import javafx.css.StyleableStringProperty;
			import javafx.scene.layout.Pane;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			
			@SuppressWarnings("all")
			public class Item extends Pane {
			  private int nonBindable;
			  
			  @BindableProperty
			  private final StyleableDoubleProperty _somethingProperty = new javafx.css.SimpleStyleableDoubleProperty(SOMETHING, this, "something", 0.0);
			  
			  public final double getSomething() {
			    return _somethingProperty.get();
			  }
			  
			  public final void setSomething(final double value) {
			    _somethingProperty.set(value);
			  }
			  
			  public final StyleableDoubleProperty somethingProperty() {
			    return _somethingProperty;
			  }
			  
			  private final static CssMetaData<Item, Number> SOMETHING = new javafx.css.CssMetaData<Item, java.lang.Number>(
			    "-something", javafx.css.StyleConverter.getSizeConverter(), 0.0) {
			    
			      @Override
			      public boolean isSettable(Item styleable) {
			        return styleable._somethingProperty == null || !styleable._somethingProperty.isBound();
			      }
			    
			      @Override
			      public javafx.css.StyleableProperty<java.lang.Number> getStyleableProperty(Item styleable) {
			        return styleable.somethingProperty();
			      }
			    }
			    ;
			  
			  @BindableProperty
			  private final StyleableStringProperty _somethingElseProperty = new javafx.css.SimpleStyleableStringProperty(SOMETHINGELSE, this, "somethingElse", "yolo");
			  
			  public final String getSomethingElse() {
			    return _somethingElseProperty.get();
			  }
			  
			  public final void setSomethingElse(final String value) {
			    _somethingElseProperty.set(value);
			  }
			  
			  public final StyleableStringProperty somethingElseProperty() {
			    return _somethingElseProperty;
			  }
			  
			  private final static CssMetaData<Item, String> SOMETHINGELSE = new javafx.css.CssMetaData<Item, java.lang.String>(
			    "-something-else", javafx.css.StyleConverter.getStringConverter(), "yolo") {
			    
			      @Override
			      public boolean isSettable(Item styleable) {
			        return styleable._somethingElseProperty == null || !styleable._somethingElseProperty.isBound();
			      }
			    
			      @Override
			      public javafx.css.StyleableProperty<java.lang.String> getStyleableProperty(Item styleable) {
			        return styleable.somethingElseProperty();
			      }
			    }
			    ;
			  
			  private static List<CssMetaData<? extends Styleable, ?>> cssMetaDataList;
			  
			  private final static Boolean cssInitialized = initializeCss();
			  
			  private static final Boolean initializeCss() {
			    java.util.List<javafx.css.CssMetaData<? extends javafx.css.Styleable, ? extends java.lang.Object>> temp = com.google.common.collect.Lists.newArrayList(Pane.getClassCssMetaData());
			    temp.add(SOMETHING);
			    temp.add(SOMETHINGELSE);
			    cssMetaDataList = java.util.Collections.unmodifiableList(temp);
			    return true;
			  }
			  
			  public static List<CssMetaData<? extends Styleable, ?>> getClassCssMetaData() {
			    return cssMetaDataList;
			  }
			  
			  public List<CssMetaData<? extends Styleable, ?>> getCssMetaData() {
			    return getClassCssMetaData();
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
	@Test
	def void testFXBeanNestedTypeObjectProperty() {
		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Something
			
			class Item {
				
				 @BindableProperty Something.Nested something
			}
		'''
		
		val output = '''
			import javafx.beans.property.ObjectProperty;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			import net.bbmsoft.fxtended.annotations.binding.Something;
			
			@SuppressWarnings("all")
			public class Item {
			  @BindableProperty
			  private final ObjectProperty<Something.Nested> _somethingProperty = new javafx.beans.property.SimpleObjectProperty<net.bbmsoft.fxtended.annotations.binding.Something.Nested>(this, "something");
			  
			  public final Something.Nested getSomething() {
			    return _somethingProperty.get();
			  }
			  
			  public final void setSomething(final Something.Nested value) {
			    _somethingProperty.set(value);
			  }
			  
			  public final ObjectProperty<Something.Nested> somethingProperty() {
			    return _somethingProperty;
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
	@Test
	def void testFXBeanStyleableEnum() {

		val input = '''
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty
			import net.bbmsoft.fxtended.annotations.binding.Something
			import net.bbmsoft.fxtended.annotations.binding.Styleable
			import javafx.scene.layout.Pane
			
			class Item extends Pane {
				
				 int nonBindable
				 
				 @Styleable("-something") @BindableProperty Something something = Something.A
			}
		'''

		val output = '''
			import java.util.List;
			import javafx.css.CssMetaData;
			import javafx.css.Styleable;
			import javafx.css.StyleableObjectProperty;
			import javafx.scene.layout.Pane;
			import net.bbmsoft.fxtended.annotations.binding.BindableProperty;
			import net.bbmsoft.fxtended.annotations.binding.Something;
			
			@SuppressWarnings("all")
			public class Item extends Pane {
			  private int nonBindable;
			  
			  @BindableProperty
			  private final StyleableObjectProperty<Something> _somethingProperty = new javafx.css.SimpleStyleableObjectProperty<net.bbmsoft.fxtended.annotations.binding.Something>(SOMETHING, this, "something", Something.A);
			  
			  public final Something getSomething() {
			    return _somethingProperty.get();
			  }
			  
			  public final void setSomething(final Something value) {
			    _somethingProperty.set(value);
			  }
			  
			  public final StyleableObjectProperty<Something> somethingProperty() {
			    return _somethingProperty;
			  }
			  
			  private final static CssMetaData<Item, Something> SOMETHING = new javafx.css.CssMetaData<Item, net.bbmsoft.fxtended.annotations.binding.Something>(
			    "-something", net.bbmsoft.fxtended.annotations.binding.StyleableEnumHelper.getEnumConverter(net.bbmsoft.fxtended.annotations.binding.Something.class), Something.A) {
			    
			      @Override
			      public boolean isSettable(Item styleable) {
			        return styleable._somethingProperty == null || !styleable._somethingProperty.isBound();
			      }
			    
			      @Override
			      public javafx.css.StyleableProperty<net.bbmsoft.fxtended.annotations.binding.Something> getStyleableProperty(Item styleable) {
			        return styleable.somethingProperty();
			      }
			    }
			    ;
			  
			  private static List<CssMetaData<? extends Styleable, ?>> cssMetaDataList;
			  
			  private final static Boolean cssInitialized = initializeCss();
			  
			  private static final Boolean initializeCss() {
			    java.util.List<javafx.css.CssMetaData<? extends javafx.css.Styleable, ? extends java.lang.Object>> temp = com.google.common.collect.Lists.newArrayList(Pane.getClassCssMetaData());
			    temp.add(SOMETHING);
			    cssMetaDataList = java.util.Collections.unmodifiableList(temp);
			    return true;
			  }
			  
			  public static List<CssMetaData<? extends Styleable, ?>> getClassCssMetaData() {
			    return cssMetaDataList;
			  }
			  
			  public List<CssMetaData<? extends Styleable, ?>> getCssMetaData() {
			    return getClassCssMetaData();
			  }
			}
		'''

		input.assertCompilesTo(output)
	}
	
}
