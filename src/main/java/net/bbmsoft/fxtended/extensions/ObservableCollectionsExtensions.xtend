package net.bbmsoft.fxtended.extensions

import java.util.List
import javafx.collections.ListChangeListener.Change
import javafx.collections.MapChangeListener
import javafx.collections.ObservableList
import javafx.collections.ObservableMap

class ObservableCollectionsExtensions {
	
	def static <T> void >> (ObservableList<? extends T> a, List<T> b) {
		a.push(b)
	}
	
	def static <T, U> void >> (ObservableList<T> a, Pair<List<U>, (T) => U> b) {
		a.push(b.key, b.value)
	}
	
	def static <T, U> void >> (ObservableMap<?extends U, ? extends T> a, List<T> b) {
		a.push(b)
	}
	
	def static <T, U, V> void >> (ObservableMap<?extends U, T> a, Pair<List<V>, (T) => V> b) {
		a.push(b.key, b.value)
	}
	
	def static <T> void << (List<T> a, ObservableList<? extends T> b) {
		a.pull(b)
	}
	
	def static <T, U> void << (List<T> a, ObservableMap<?extends U, ? extends T> b) {
		a.pull(b)
	}
	
	def static <T> void push(ObservableList<? extends T> a, List<T> b) {
		a.addListener[Change<? extends T> c |
			while(c.next) {
				b.removeAll(c.removed)
				b.addAll(c.addedSubList)
			}
		]
	}
	
	def static <T, U> void push(ObservableList<T> a, List<U> b, (T) => U fun) {
		a.addListener[Change<? extends T> c |
			while(c.next) {
				b.removeAll(c.removed.map(fun))
				b.addAll(c.addedSubList.map(fun))
			}
		]
	}
	
	def static <T, U> void push(ObservableMap<? extends U, ? extends T> a, List<T> b) {
		a.addListener[MapChangeListener.Change<? extends U, ? extends T> it |
			val added = valueAdded
			val removed = valueRemoved
			if(removed !== null) b.remove(removed)
			if(added !== null) b.add(added)
		]
	}
	
	def static <T, U, V> void push(ObservableMap<? extends U, T> a, List<V> b, extension (T) => V fun) {
		a.addListener[MapChangeListener.Change<? extends U, ? extends T> it |
			val added = valueAdded
			val removed = valueRemoved
			if(removed !== null) b.remove(removed.apply)
			if(added !== null) b.add(added.apply)
		]
	}
	
	def static <T> void pull(List<T> a, ObservableList<? extends T> b) {
		b.addListener[Change<? extends T> c |
			while(c.next) {
				a.removeAll(c.removed)
				a.addAll(c.addedSubList)
			}
		]
	}
	
	def static <T, U> void pull(List<U> a, ObservableList<T> b, (T) => U fun) {
		b.addListener[Change<? extends T> c |
			while(c.next) {
				a.removeAll(c.removed.map(fun))
				a.addAll(c.addedSubList.map(fun))
			}
		]
	}
	
	def static <T, U> void pull(List<T> a, ObservableMap<? extends U, ? extends T> b) {
		b.addListener[MapChangeListener.Change<? extends U, ? extends T> it |
			val added = valueAdded
			val removed = valueRemoved
			if(removed !== null) a.remove(removed)
			if(added !== null) a.add(added)
		]
	}
	
	def static <T, U, V> void pull(List<V> a, ObservableMap<? extends U, T> b, extension (T) => V fun) {
		b.addListener[MapChangeListener.Change<? extends U, ? extends T> it |
			val added = valueAdded
			val removed = valueRemoved
			if(removed !== null) a.remove(removed.apply)
			if(added !== null) a.add(added.apply)
		]
	}
}