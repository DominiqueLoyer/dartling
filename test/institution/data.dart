
EcoleEntry fromJsonToEcoleEntry() {
  /**
   *  || Ecole
   *  id numero
   *  req nom
   *  at address
   */
  var _json = '''
  {"width":990,"lines":[],"height":580,"boxes":[{"entry":true,"name":"Ecole","x":342,"y":252,"width":120,"height":120,"items":[{"sequence":10,"category":"identifier","name":"numero","type":"int","init":""},{"sequence":20,"category":"required","name":"nom","type":"String","init":""},
  {"sequence":30,"category":"attribute","name":"address","type":"String","init":""}]}]}    ''';
  return new EcoleEntry(fromMagicBoxes(_json));
}

class EcoleReaction implements ActionReaction {

  bool reactedOnAdd = false;
  bool reactedOnUpdate = false;

  react(Action action) {
    if (action is EntitiesAction) {
      reactedOnAdd = true;
    } else if (action is EntityAction) {
      reactedOnUpdate = true;
    }
  }

}

testInstitutionData() {
  var entry;
  var session;
  var data;
  var ecoles;
  var ecoleConcept;
  var ecoleCount;
  var uLavalOid;
  group('Testing Institution', () {
    setUp(() {
      entry = fromJsonToEcoleEntry();
      data = entry.data;
      session = entry.newSession();

      ecoleConcept = data.ecoleConcept;
      expect(ecoleConcept, isNotNull);
      expect(ecoleConcept.attributes, isNot(isEmpty));
      expect(ecoleConcept.attributes.count, equals(3));

      ecoleCount = 0;

      ecoles = data.ecoles;
      expect(ecoles, isNotNull);
      expect(ecoles.count, equals(ecoleCount));

      var lavalHighScool = new Ecole(ecoleConcept);
      expect(lavalHighScool, isNotNull);
      lavalHighScool.numero = 2;
      lavalHighScool.nom = 'Laval School';
      lavalHighScool.adress = '1307 Chemin Sainte Foy';
      ecoles.add(lavalHighScool);
      expect(ecoles.count, equals(++ecoleCount));

      var abcScool = new Ecole(ecoleConcept);
      expect(abcScool, isNotNull);
      abcScool.numero = 3;
      abcScool.nom = 'Abc School';
      abcScool.adress = '122 Chemain Quatre bourgeois';
      ecoles.add(abcScool);
      expect(ecoles.count, equals(++ecoleCount));

      var uLaval = new Ecole(ecoleConcept);
      expect(uLaval, isNotNull);
      uLaval.numero = 1;
      uLaval.nom = 'Laval Univ';
      uLaval.adress = '1245 Rue University';
      ecoles.add(uLaval);
      expect(ecoles.count, equals(++ecoleCount));
      uLavalOid = uLaval.oid;
      expect(uLavalOid, isNotNull);
      var ul = ecoles.find(uLavalOid);
      expect(ul, isNotNull);
    });
    tearDown(() {
      ecoles.clear();
      expect(ecoles.count, equals(0));
    });
    test('Select Ecoles by Attribute', () {
      ecoles.display('All Ecoles');

      Ecoles selectedEcoles =
          ecoles.selectByAttribute('nom', 'Laval School');
      expect(selectedEcoles, isNotNull);
      expect(selectedEcoles, isNot(isEmpty));
      expect(selectedEcoles.count, equals(1));
      expect(selectedEcoles.source, isNotNull);
      expect(selectedEcoles.source, isNot(isEmpty));
      expect(selectedEcoles.source.count, equals(ecoleCount));

      selectedEcoles.display('Selected Ecoles');
    });
    test('Select Ecoles by Attribute then Remove', () {
      Ecoles selectedEcoles =
          ecoles.selectByAttribute('nom', 'Laval Univ');
      expect(selectedEcoles, isNotNull);
      expect(selectedEcoles, isNot(isEmpty));
      expect(selectedEcoles.count, equals(1));
      expect(selectedEcoles.source, isNotNull);
      expect(selectedEcoles.source, isNot(isEmpty));
      expect(selectedEcoles.source.count, equals(ecoleCount));

      selectedEcoles.display('Selected Ecoles Before Remove');
      expect(selectedEcoles.count, equals(1));
      expect(ecoles.count, equals(ecoleCount));
      var uLaval = selectedEcoles.find(uLavalOid);
      expect(uLaval, isNotNull);
      selectedEcoles.remove(uLaval);
      expect(selectedEcoles.count, equals(0));
      expect(ecoles.count, equals(--ecoleCount));

      selectedEcoles.display('Selected Ecoles After Remove');
      ecoles.display('All Ecoles After Remove');
    });
    test('Order Ecoles by Numero', () {
      Ecoles orderedEcoles = ecoles.order();
      expect(orderedEcoles, isNotNull);
      expect(orderedEcoles, isNot(isEmpty));
      expect(orderedEcoles.count, equals(ecoleCount));
      expect(orderedEcoles.source, isNotNull);
      expect(orderedEcoles.source, isNot(isEmpty));
      expect(orderedEcoles.source.count, equals(ecoleCount));
      orderedEcoles.display('Ecoles Ordered by Numero');
    });
    test('Order Ecoles by Nom', () {
      Ecoles orderedEcoles =
          ecoles.orderByFunction((m,n) => m.compareNom(n));
      expect(orderedEcoles, isNotNull);
      expect(orderedEcoles, isNot(isEmpty));
      expect(orderedEcoles.count, equals(ecoleCount));
      expect(orderedEcoles.source, isNotNull);
      expect(orderedEcoles.source, isNot(isEmpty));
      expect(orderedEcoles.source.count, equals(ecoleCount));
      orderedEcoles.display('Ecoles Ordered by Nom');
    });
    
    test('Order Ecoles by Address', () {
      Ecoles orderedEcoles =
          ecoles.orderByFunction((m,n) => m.compareAddress(n));
      expect(orderedEcoles, isNotNull);
      expect(orderedEcoles, isNot(isEmpty));
      expect(orderedEcoles.count, equals(ecoleCount));
      expect(orderedEcoles.source, isNotNull);
      expect(orderedEcoles.source, isNot(isEmpty));
      expect(orderedEcoles.source.count, equals(ecoleCount));
      orderedEcoles.display('Ecoles Ordered by Address');
    });
    test('New Member Undo', () {
      var yyySchool = new Ecole(ecoleConcept);
      expect(yyySchool, isNotNull);
      yyySchool.numero = 4;
      yyySchool.nom = 'YYY School';
      yyySchool.adress = 'New Orleans 11 St';

      var action = new AddAction(session, ecoles, yyySchool);
      action.doit();
      expect(ecoles.count, equals(++ecoleCount));

      session.past.undo();
      expect(ecoles.count, equals(--ecoleCount));

      session.past.redo();
      expect(ecoles.count, equals(++ecoleCount));
    });
    test('Reactions to Ecole Actions', () {
      var reaction = new EcoleReaction();
      expect(reaction, isNotNull);

      entry.startActionReaction(reaction);
      var yyySchool = new Ecole(ecoleConcept);
      expect(yyySchool, isNotNull);
      yyySchool.numero = 4;
      yyySchool.nom = 'YYY School';
      yyySchool.adress = 'New Orleans 11 St';
      
      var action = new AddAction(session, ecoles, yyySchool);
      action.doit();
      expect(ecoles.count, equals(++ecoleCount));
      expect(reaction.reactedOnAdd, isTrue);

      entry.cancelActionReaction(reaction);
    });
    
  });
}

