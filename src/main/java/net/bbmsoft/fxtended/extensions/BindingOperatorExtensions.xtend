package net.bbmsoft.fxtended.extensions

import java.util.List
import java.util.Locale
import java.util.Map
import javafx.beans.InvalidationListener
import javafx.beans.Observable
import javafx.beans.binding.BooleanBinding
import javafx.beans.binding.BooleanExpression
import javafx.beans.binding.NumberBinding
import javafx.beans.binding.NumberExpression
import javafx.beans.binding.ObjectBinding
import javafx.beans.binding.ObjectExpression
import javafx.beans.binding.StringExpression
import javafx.beans.property.Property
import javafx.beans.value.ChangeListener
import javafx.beans.value.ObservableBooleanValue
import javafx.beans.value.ObservableNumberValue
import javafx.beans.value.ObservableObjectValue
import javafx.beans.value.ObservableStringValue
import javafx.beans.value.ObservableValue
import javafx.collections.ListChangeListener
import javafx.collections.ListChangeListener.Change
import javafx.collections.MapChangeListener
import javafx.collections.ObservableList
import javafx.collections.ObservableMap
import javafx.collections.ObservableSet
import javafx.collections.SetChangeListener
import javafx.css.PseudoClass
import javafx.event.Event
import javafx.event.EventHandler
import javafx.event.EventType
import javafx.scene.Node

import static extension java.util.Objects.*

class BindingOperatorExtensions {

	// property binding
	def static <T> void <<(Property<T> a, ObservableValue<? extends T> b) {

		a.requireNonNull
		b.requireNonNull

		a.unbind
		a.bind(b)
	}

	def static <T> void <>(Property<T> a, Property<T> b) {

		a.requireNonNull
		b.requireNonNull

		a.unbind
		b.unbind
		a.bindBidirectional(b)
	}

	def static <T> void <<(Property<T> a, ()=>T b) {

		a.requireNonNull
		b.requireNonNull

		a.unbind

		val value = new ObjectBinding<T>() {
			override protected computeValue() {
				b.apply
			}
		}

		a.bind(value)
	}

	// listeners and handlers
	def static void >(Observable o, InvalidationListener l) {

		o.requireNonNull
		l.requireNonNull

		o.addListener(l)
	}

	def static void -(Observable o, InvalidationListener l) {

		o.requireNonNull
		l.requireNonNull

		o.removeListener(l)
	}

	def static <O extends Observable> void >(Iterable<O> os, InvalidationListener l) {

		os.requireNonNull
		l.requireNonNull

		os.forEach[addListener(l)]
	}

	def static <O extends Observable> void -(Iterable<O> os, InvalidationListener l) {

		os.requireNonNull
		l.requireNonNull

		os.forEach[removeListener(l)]
	}

	def static <T> ChangeListener<T> >>(ObservableValue<? extends T> a, extension (T)=>void consumer) {

		a.requireNonNull
		consumer.requireNonNull

		val ChangeListener<T> listener = [o, oldVal, newVal|consumer.apply(newVal)]
		a.addListener(listener)
		a.value?.apply
		return listener
	}

	def static <T> ChangeListener<T> >>(ObservableValue<? extends T> a, (T, T)=>void consumer) {

		a.requireNonNull
		consumer.requireNonNull

		val ChangeListener<T> listener = [ ObservableValue<? extends T> o, T oldVal, T newVal |
			consumer.apply(oldVal, newVal)
		]
		a.addListener(listener)
		if(a.value !== null) consumer.apply(null, a.value)
		return listener
	}

	def static <T> void >>(ObservableValue<? extends T> a, ChangeListener<T> listener) {

		a.requireNonNull
		listener.requireNonNull

		a.addListener(listener)
	}

	def static <T> void -(ObservableValue<? extends T> a, ChangeListener<T> listener) {

		a.requireNonNull
		listener.requireNonNull

		a.removeListener(listener)
	}

	def static <T> ListChangeListener<T> >>(ObservableList<T> a,
		extension (List<? extends T>, List<? extends T>)=>void consumer) {

		a.requireNonNull
		consumer.requireNonNull

		val ListChangeListener<T> listener = [ Change<? extends T> c |

			while (c.next) {

				val add = c.addedSubList
				val rem = c.removed

				consumer.apply(add, rem)
			}
		]

		a.addListener(listener)
		a.apply(newArrayList)

		return listener
	}

	def static <T> void -(ObservableList<T> a, ListChangeListener<T> listener) {

		a.requireNonNull
		listener.requireNonNull

		a.removeListener(listener)
	}

	def static <T, U> void >>(ObservableMap<? extends T, ? extends U> a,
		MapChangeListener<? super T, ? super U> listener) {

		a.requireNonNull
		listener.requireNonNull

		a.addListener(listener)
	}

	def static <T, U> MapChangeListener<T, U> >>(ObservableMap<T, U> a, extension (T, U, U)=>void consumer) {

		a.requireNonNull
		consumer.requireNonNull

		val MapChangeListener<T, U> listener = [ extension change |
			consumer.apply(key, valueAdded, valueRemoved)
		]

		a.addListener(listener)
		a.keySet.forEach[apply(a.get(it), null)]
		return listener
	}

	def static ChangeListener<? super Boolean> >>(ObservableValue<Boolean> property,
		Pair<Node, PseudoClass> styleableClass) {

		property.requireNonNull
		styleableClass.requireNonNull

		val node = styleableClass.key
		val pseudoClass = styleableClass.value

		node.requireNonNull
		pseudoClass.requireNonNull

		val listener = [ ObservableValue<? extends Boolean> o, Boolean oldVal, Boolean newVal |
			node.pseudoClassStateChanged(pseudoClass, newVal)
		]

		property.addListener(listener)
		node.pseudoClassStateChanged(pseudoClass, property.value)
		return listener
	}

	def static <T extends Event> EventHandler<T> >>(Node node, Pair<EventType<T>, EventHandler<T>> typeHandler) {

		node.requireNonNull
		typeHandler.requireNonNull

		val type = typeHandler.key
		val handler = typeHandler.value
		node.addEventHandler(type, handler)
		return handler
	}

	def static <T extends Event> void -(Node node, Pair<EventType<T>, EventHandler<T>> typeHandler) {

		node.requireNonNull
		typeHandler.requireNonNull

		val type = typeHandler.key
		val handler = typeHandler.value
		node.removeEventHandler(type, handler)
	}

	def static <T> SetChangeListener<T> >>(ObservableSet<T> a, (T, T)=>void consumer) {

		a.requireNonNull
		consumer.requireNonNull

		val SetChangeListener<T> listener = [ SetChangeListener.Change<? extends T> c |

			consumer.apply(c.elementAdded, c.elementRemoved)
		]

		a.addListener(listener)
		a.forEach[consumer.apply(it, null)]
		return listener
	}

	def static <T> void -(ObservableSet<T> a, SetChangeListener<T> listener) {

		a.requireNonNull
		listener.requireNonNull

		a.removeListener(listener)
	}

	// String bindings
	// Plus
	def static StringExpression +(StringExpression a, ObservableStringValue b) {
		a.concat(b)
	}

	// number bindings
	// Plus
	def static NumberBinding +(NumberExpression a, ObservableNumberValue b) {
		a.add(b)
	}

	def static NumberBinding +(NumberExpression a, double b) {
		a.add(b)
	}

	def static NumberBinding +(NumberExpression a, float b) {
		a.add(b)
	}

	def static NumberBinding +(NumberExpression a, long b) {
		a.add(b)
	}

	def static NumberBinding +(NumberExpression a, int b) {
		a.add(b)
	}

	// Minus
	def static NumberBinding -(NumberExpression a, ObservableNumberValue b) {
		a.subtract(b)
	}

	def static NumberBinding -(NumberExpression a, double b) {
		a.subtract(b)
	}

	def static NumberBinding -(NumberExpression a, float b) {
		a.subtract(b)
	}

	def static NumberBinding -(NumberExpression a, long b) {
		a.subtract(b)
	}

	def static NumberBinding -(NumberExpression a, int b) {
		a.subtract(b)
	}

	def static NumberBinding -(NumberExpression a) {
		a.negate
	}

	// Times
	def static NumberBinding *(NumberExpression a, ObservableNumberValue b) {
		a.multiply(b)
	}

	def static NumberBinding *(NumberExpression a, double b) {
		a.multiply(b)
	}

	def static NumberBinding *(NumberExpression a, float b) {
		a.multiply(b)
	}

	def static NumberBinding *(NumberExpression a, long b) {
		a.multiply(b)
	}

	def static NumberBinding *(NumberExpression a, int b) {
		a.multiply(b)
	}

	// DividedBy
	def static NumberBinding /(NumberExpression a, ObservableNumberValue b) {
		a.divide(b)
	}

	def static NumberBinding /(NumberExpression a, double b) {
		a.divide(b)
	}

	def static NumberBinding /(NumberExpression a, float b) {
		a.divide(b)
	}

	def static NumberBinding /(NumberExpression a, long b) {
		a.divide(b)
	}

	def static NumberBinding /(NumberExpression a, int b) {
		a.divide(b)
	}

	// IsEqualTo
	def static BooleanBinding ==(NumberExpression a, ObservableNumberValue b) {
		a.isEqualTo(b)
	}

	def static BooleanBinding ==(NumberExpression a, double b) {
		a.isEqualTo(b, 0d)
	}

	def static BooleanBinding ==(NumberExpression a, float b) {
		a.isEqualTo(b, 0d)
	}

	def static BooleanBinding ==(NumberExpression a, long b) {
		a.isEqualTo(b)
	}

	def static BooleanBinding ==(NumberExpression a, int b) {
		a.isEqualTo(b)
	}

	// IsNotEqualTo
	def static BooleanBinding !=(NumberExpression a, ObservableNumberValue b) {
		a.isNotEqualTo(b)
	}

	def static BooleanBinding !=(NumberExpression a, double b) {
		a.isNotEqualTo(b, 0d)
	}

	def static BooleanBinding !=(NumberExpression a, float b) {
		a.isNotEqualTo(b, 0d)
	}

	def static BooleanBinding !=(NumberExpression a, long b) {
		a.isNotEqualTo(b)
	}

	def static BooleanBinding !=(NumberExpression a, int b) {
		a.isNotEqualTo(b)
	}

	// IsGreaterThan
	def static BooleanBinding >(NumberExpression a, ObservableNumberValue b) {
		a.greaterThan(b)
	}

	def static BooleanBinding >(NumberExpression a, double b) {
		a.greaterThan(b)
	}

	def static BooleanBinding >(NumberExpression a, float b) {
		a.greaterThan(b)
	}

	def static BooleanBinding >(NumberExpression a, long b) {
		a.greaterThan(b)
	}

	def static BooleanBinding >(NumberExpression a, int b) {
		a.greaterThan(b)
	}

	// IsLessThan
	def static BooleanBinding <(NumberExpression a, ObservableNumberValue b) {
		a.lessThan(b)
	}

	def static BooleanBinding <(NumberExpression a, double b) {
		a.lessThan(b)
	}

	def static BooleanBinding <(NumberExpression a, float b) {
		a.lessThan(b)
	}

	def static BooleanBinding <(NumberExpression a, long b) {
		a.lessThan(b)
	}

	def static BooleanBinding <(NumberExpression a, int b) {
		a.lessThan(b)
	}

	// IsGreaterThanOrEqualTo
	def static BooleanBinding >=(NumberExpression a, ObservableNumberValue b) {
		a.greaterThanOrEqualTo(b)
	}

	def static BooleanBinding >=(NumberExpression a, double b) {
		a.greaterThanOrEqualTo(b)
	}

	def static BooleanBinding >=(NumberExpression a, float b) {
		a.greaterThanOrEqualTo(b)
	}

	def static BooleanBinding >=(NumberExpression a, long b) {
		a.greaterThanOrEqualTo(b)
	}

	def static BooleanBinding >=(NumberExpression a, int b) {
		a.greaterThanOrEqualTo(b)
	}

	// IsLessThanOrEqualTo
	def static BooleanBinding &&(NumberExpression a, ObservableNumberValue b) {
		a.lessThanOrEqualTo(b)
	}

	def static BooleanBinding <=(NumberExpression a, double b) {
		a.lessThanOrEqualTo(b)
	}

	def static BooleanBinding <=(NumberExpression a, float b) {
		a.lessThanOrEqualTo(b)
	}

	def static BooleanBinding <=(NumberExpression a, long b) {
		a.lessThanOrEqualTo(b)
	}

	def static BooleanBinding <=(NumberExpression a, int b) {
		a.lessThanOrEqualTo(b)
	}

	// boolean bindings
	def static BooleanBinding &&(BooleanExpression a, ObservableBooleanValue b) {
		a.and(b)
	}

	def static BooleanBinding ||(BooleanExpression a, ObservableBooleanValue b) {
		a.or(b)
	}

	// object bindings
	def static <T> BooleanBinding ==(ObjectExpression<T> a, ObservableObjectValue<T> b) {
		a.isEqualTo(b)
	}

	def static <T> BooleanBinding ==(ObjectExpression<T> a, T b) {
		a.isEqualTo(b)
	}

	def static <T> BooleanBinding !=(ObjectExpression<T> a, ObservableObjectValue<T> b) {
		a.isNotEqualTo(b)
	}

	def static <T> BooleanBinding !=(ObjectExpression<T> a, T b) {
		a.isNotEqualTo(b)
	}
	
	// pseudoclass bindings
	
	def static <E extends Enum<?>> void asPseudoClassesFor (ObservableValue<E> theEnum, Node node) {
		
		theEnum.addListener(new EnumPseudoclassListener(node, theEnum))
	}
	
	static class EnumPseudoclassListener<E extends Enum<?>> implements ChangeListener<E> {

		final Object lock
		final Map<E, PseudoClass> pseudoClasses

		final Node node
		
		final boolean initialized

		new(Node node, ObservableValue<E> property) {

			this.node = node
			this.lock = new Object
			this.pseudoClasses = newHashMap
			
			this.initialized = initialize(property)
		}
	
		private def initialize(ObservableValue<E> property) {
			val value = property.value
			if(value !== null) {
				value.class.enumConstants.forEach[
					PseudoClass.getPseudoClass(toString.toLowerCase(Locale.US)) => [className |
						pseudoClasses.put(it as E, className)
					]
				]
				true
			} else {
				false	
			}
		}

		override changed(ObservableValue<? extends E> observable, E oldValue, E newValue) {

			if (initialized) {
				handleChange(oldValue, newValue)
			} else {
				synchronized (lock) {
					handleChange(oldValue, newValue)
				}
			}
		}
		
		private def handleChange(E oldValue, E newValue) {
			if (oldValue !== null) {
				val oldPseudoClass = pseudoClasses.get(oldValue) ?:
					(PseudoClass.getPseudoClass(newValue.toString.toLowerCase(Locale.US)) => [
						pseudoClasses.put(oldValue, it)
					])
				node.pseudoClassStateChanged(oldPseudoClass, false)
			}
			
			if (newValue !== null) {
				val newPseudoClass = pseudoClasses.get(newValue) ?:
					(PseudoClass.getPseudoClass(newValue.toString.toLowerCase(Locale.US)) => [
						pseudoClasses.put(newValue, it)
					])
				node.pseudoClassStateChanged(newPseudoClass, true)
			}
		}

	}
}
