# URCS Rollen & Toegang

## 👥 Rollen & Toegang

Het systeem kent verschillende gebruikersrollen met specifieke rechten:

### SuperAdmin
- Kan alle restaurants zien en beheren
- Kan restaurants toevoegen/bewerken/verwijderen
- Kan alle medewerkers zien en beheren
- Heeft toegang tot alle functionaliteit

### Restaurant Eigenaar (Owner)
- Kan alleen eigen restaurant zien
- Kan medewerkers in eigen restaurant beheren
- Kan managers aanstellen
- Kan uren goedkeuren
- Kan restaurant informatie zien maar niet bewerken

### Manager
- Kan alleen eigen restaurant zien
- Kan uren goedkeuren
- Kan medewerkers in eigen restaurant zien
- Kan eigen gegevens bewerken

### Medewerker (Employee)
- Kan alleen eigen restaurant zien
- Kan collega's in eigen restaurant zien
- Kan eigen uren registreren
- Kan eigen gegevens bewerken

### Functionaliteit per Onderdeel

**Restaurants**
- SuperAdmin: Volledig beheer
- Eigenaar: Alleen zichtbaar, geen bewerkingen
- Manager/Medewerker: Alleen zichtbaar, geen bewerkingen

**Medewerkers**
- SuperAdmin: Volledig beheer over alle medewerkers
- Eigenaar: Beheer over medewerkers in eigen restaurant
- Manager: Alleen zichtbaar, kan uren goedkeuren
- Medewerker: Alleen zichtbaar

**Urenregistratie**
- SuperAdmin: Kan alle uren zien en bewerken
- Eigenaar: Kan uren zien en goedkeuren in eigen restaurant
- Manager: Kan uren zien en goedkeuren in eigen restaurant
- Medewerker: Kan alleen eigen uren registreren

**Jaaroverzicht**
- SuperAdmin: Kan alle restaurants selecteren
- Eigenaar: Ziet alleen eigen restaurant
- Manager: Ziet alleen eigen restaurant
- Medewerker: Ziet alleen eigen restaurant

Voor test accounts en meer details, zie [ROLLEN.MD](ROLLEN.MD)

## Test Accounts

### Superadmin
- Email: laventejeffrey@gmail.com
- Wachtwoord: Bootje@12

### Restaurant Cemil
**Eigenaar**
- Email: owner@urcs.nl
- Wachtwoord: owner123

**Manager**
- Email: manager@urcs.nl
- Wachtwoord: manager123

**Medewerker**
- Email: employee@urcs.nl
- Wachtwoord: employee123

### Restaurant Test
**Eigenaar**
- Email: test.owner@urcs.nl
- Wachtwoord: owner123

**Manager**
- Email: test.manager@urcs.nl
- Wachtwoord: manager123

**Medewerker**
- Email: test.employee@urcs.nl
- Wachtwoord: employee123

## Rechten per Rol

### Superadmin
- Kan alle restaurants zien en beheren
- Kan restaurants toevoegen/bewerken/verwijderen
- Kan alle medewerkers zien en beheren
- Heeft toegang tot alle functionaliteit

### Restaurant Eigenaar
- Kan alleen eigen restaurant zien
- Kan medewerkers in eigen restaurant beheren
- Kan managers aanstellen
- Kan uren goedkeuren
- Kan restaurant informatie zien maar niet bewerken

### Manager
- Kan alleen eigen restaurant zien
- Kan uren goedkeuren
- Kan medewerkers in eigen restaurant zien
- Kan eigen gegevens bewerken

### Medewerker
- Kan alleen eigen restaurant zien
- Kan collega's in eigen restaurant zien
- Kan eigen uren registreren
- Kan eigen gegevens bewerken

## Functionaliteit per Scherm

### Restaurants
- **Superadmin**: Volledig beheer
- **Eigenaar**: Alleen zichtbaar, geen bewerkingen
- **Manager/Medewerker**: Alleen zichtbaar, geen bewerkingen

### Medewerkers
- **Superadmin**: Volledig beheer over alle medewerkers
- **Eigenaar**: Beheer over medewerkers in eigen restaurant
- **Manager**: Alleen zichtbaar, kan uren goedkeuren
- **Medewerker**: Alleen zichtbaar

### Urenregistratie
- **Superadmin**: Kan alle uren zien en bewerken
- **Eigenaar**: Kan uren zien en goedkeuren in eigen restaurant
- **Manager**: Kan uren zien en goedkeuren in eigen restaurant
- **Medewerker**: Kan alleen eigen uren registreren

### Jaaroverzicht
- **Superadmin**: Kan alle restaurants selecteren
- **Eigenaar**: Ziet alleen eigen restaurant
- **Manager**: Ziet alleen eigen restaurant
- **Medewerker**: Ziet alleen eigen restaurant