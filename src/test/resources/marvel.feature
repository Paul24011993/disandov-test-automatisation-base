@MarvelAPI @Agent
Feature: Evaluacion Chapter Desarrollo - Marvel Characters

  Background:
    * def baseEndpoint = 'http://bp-se-test-cabcd9b246a5.herokuapp.com'
    * def user = 'disandov'
    * def urlBase = baseEndpoint + '/' + user + '/api'
    * header Content-Type = 'application/json'
    * def newId = 38

  @createCharacter
  Scenario: Crear personaje exitosamente
    Given url urlBase + '/characters'
    And request
    """
    {
      name: 'IronMan',
      alterego: 'Tony Stark',
      description: 'Genius billionaire',
      powers: ['Armor', 'Flight']
    }
    """
    When method POST
    Then status 201
    And match response contains { name: 'IronMan', alterego: 'Tony Stark' }
    * def createdId = response.id
    * print 'ID creado:', createdId

  @createDuplicate
  Scenario: Crear personaje con nombre duplicado
    Given url urlBase + '/characters'
    And request
    """
    {
      name: 'Superman',
      alterego: 'Otro',
      description: 'Otro',
      powers: ['Armor']
    }
    """
    When method POST
    Then status 400
    And match response == { error: 'Character name already exists' }

  @createMissingFields
  Scenario: Crear personaje con campos vacíos
    Given url urlBase + '/characters'
    And request
    """
    {
      name: '',
      alterego: '',
      description: '',
      powers: []
    }
    """
    When method POST
    Then status 400
    And match response ==
    """
    {
      name: 'Name is required',
      alterego: 'Alterego is required',
      description: 'Description is required',
      powers: 'Powers are required'
    }
    """


  @getAll
  Scenario: Obtener todos los personajes
    Given url urlBase + '/characters'
    When method GET
    Then status 200
    And match response ==
    """
    [
        {
            "id": 38,
            "name": "IronMan",
            "alterego": "Tony Stark",
            "description": "Genius billionaire",
            "powers": [ "Armor", "Flight" ]
        },
        {
            "id": 12,
            "name": "Superman",
            "alterego": "Tony Stark",
            "description": "Updated description",
            "powers": [ "Armor", "Flight" ]
        }
    ]
    """


  @getById
  Scenario: Obtener personaje por ID existente
    Given url urlBase + '/characters/' + newId
    When method GET
    Then status 200
    And match response =={ "id": 38,"name": "IronMan", "alterego": "Tony Stark","description": "Genius billionaire","powers": [ "Armor", "Flight" ] }
    * def characterName = response.name
    * print 'Nombre del personaje:', characterName

  @getByIdNotFound
  Scenario: Obtener personaje por ID inexistente
    Given url urlBase + '/characters/999'
    When method GET
    Then status 404
    And match response == { error: 'Character not found' }

  @updateCharacter
  Scenario: Actualizar personaje exitosamente
    Given url urlBase + '/characters/'+ newId
    And request
    """
    {
      name: 'IronMan',
      alterego: 'Tony Stark',
      description: 'Genius billionaire',
      powers: ['Armor', 'Flight']
    }
    """
    When method PUT
    Then status 200
    And match response contains { description: 'Genius billionaire' }

  @updateNotFound
  Scenario: Actualizar personaje inexistente
    Given url urlBase + '/characters/999'
    And request
    """
    {
      name: 'Iron Man',
      alterego: 'Tony Stark',
      description: 'Genius billionaire',
      powers: ['Armor', 'Flight']
    }
    """
    When method PUT
    Then status 404
    And match response == { error: 'Character not found' }

  @deleteCharacter
  Scenario: Eliminar personaje existente
    Given url urlBase + '/characters/'+ newId
    When method DELETE
    Then status 204

  @deleteNotFound
  Scenario: Eliminar personaje inexistente
    Given url urlBase + '/characters/999'
    When method DELETE
    Then status 404
    And match response == { error: 'Character not found' }