
class Entity<T extends Entity<T>> implements Comparable {

  Oid _oid;
  String _code;

  Concept _concept;

  Map<String, Object> _attributeMap;
  Map<String, Entity> _parentMap;
  Map<String, Entities> _childMap;

  Entity() {
    _oid = new Oid();
  }

  Entity.of(this._concept) {
    _oid = new Oid();
    _attributeMap = new Map<String, Object>();
    _parentMap = new Map<String, Entity>();
    _childMap = new Map<String, Entities>();

    for (Attribute a in _concept.attributes) {
      if (a.init != null) {
        _attributeMap[a.code] = a.init;
      } else if (a.increment != null) {
        _attributeMap[a.code] = a.increment;
      } else {
        _attributeMap[a.code] = null;
      }
    }

    for (Parent parent in _concept.destinationParents) {
      _parentMap[parent.code] = null;
    }

    for (Child child in _concept.destinationChildren) {
      var entities = new Entities();
      entities._concept = child.destinationConcept;
      _childMap[child.code] = entities;
    }
  }

  Oid get oid() => _oid;

  String get code() => _code;
  set code(String code) {
    if (_code != null) {
      throw new Exception('Entity code cannot be updated.');
    }
    if (code == null) {
      throw new Exception('Entity code cannot be nullified.');
    }
    _code = code;
  }

  Concept get concept() => _concept;

  Object getAttribute(String name) => _attributeMap[name];
  setAttribute(String name, Object value) {
    //Attribute attribute = concept.attributes.getEntity(name);
    _attributeMap[name] = value;
  }

  Entity getParent(String name) => _parentMap[name];
  setParent(String name, Entity entity) => _parentMap[name] = entity;

  Entities getChild(String name) => _childMap[name];
  setChild(String name, Entities entities) => _childMap[name] = entities;

  /**
   * Copies the entity (oid, code, attributes and neighbors).
   */
  T copy() {
    T e = new Entity.of(_concept);
    e._oid = _oid;
    e.code = _code;
    for (Attribute a in _concept.attributes) {
      e.setAttribute(a.code, _attributeMap[a.code]);
    }

    for (Parent parent in _concept.destinationParents) {
      e.setParent(parent.code, _parentMap[parent.code]);
    }

    for (Child child in _concept.destinationChildren) {
      e.setChild(child.code, _childMap[child.code]);
    }

    return e;
  }

  /**
  * Checks if the entity is equal to the given object.
  * If the given object is not of the T type,
  * two objects cannot be equal.
  * Two entities are equal if their oids are equal.
  */
  bool equals(other) {
    if (other is T) {
      if (_oid != other.oid) {
        return false;
      }
    } else {
      return false;
    }
    return true;
  }

  /**
   * Checks if the entity is equal in content to the given object.
   * If the given object is not of the T type,
   * two objects cannot be equal. Two entities are
   * equal if they have the same content, except oid.
   */
   bool equalsInContent(other) {
     if (other is T) {
       if (_code != other.code) {
         return false;
       }
       for (Attribute a in _concept.attributes) {
         if (_attributeMap[a.code] != other.getAttribute(a.code)) {
           return false;
         }
       }

       for (Parent parent in _concept.destinationParents) {
         if (_parentMap[parent.code] != other.getParent(parent.code)) {
           return false;
         }
       }

       for (Child child in _concept.destinationChildren) {
         if (_childMap[child.code] != other.getChild(child.code)) {
           return false;
         }
       }
     } else {
       return false;
     }
     return true;
   }

  /**
   * Compares two entities based on codes. If the result is less than 0 then
   * the first entity is less than the second, if it is equal to 0 they are
   * equal and if the result is greater than 0 then the first is greater than
   * the second.
   */
  int compareTo(T entity) {
    return _code.compareTo(entity.code);
  }

  /**
   * Returns a string that represents this entity by using oid and code.
   */
  String toString() {
    if (_code == null) {
      return '${_oid.toString()}';
    }
    return '${_oid.toString()} $_code';
  }

  /**
   * Displays (prints) an entity with its attributes, parents and children.
   */
  display([String space='', bool withOid=true]) {
    var s = space;
    if (_concept != null && !_concept.entry) {
      s = '$space  ';
    }
    print('${s}------------------------------------');
    print('${s}${toString()}                       ');
    print('${s}------------------------------------');
    if (withOid) {
      print('${s}oid: $_oid');
    }
    if (_code != null) {
      print('${s}code: $_code');
    }

    _attributeMap.forEach((k,v) {
      print('${s}$k: $v');
    });

    _parentMap.forEach((k,v) {
      print('${s}$k: ${v.code}');
    });

    _childMap.forEach((k,v) {
      print('${s}$k:');
      v.display(s, withOid);
    });

    print('');
  }

}