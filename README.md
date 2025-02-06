# URCS (Uren Registratie & Controle Systeem)

Een Flutter-gebaseerd systeem voor tijdregistratie en beheer, specifiek ontworpen voor restaurants en hun medewerkers.

## 🚀 Features

- 👥 **Gebruikersbeheer** met verschillende rollen (SuperAdmin, Owner, Manager, Employee)
- 🕒 **Tijdregistratie** voor medewerkers
  - Week/maand/jaar overzichten
  - Goedkeuringsworkflow
  - Automatische urenberekening
- 🏪 **Restaurant management**
  - Medewerker toewijzing
  - Restaurant statistieken
- 📊 **Uitgebreide statistieken en rapportages**
  - Jaaroverzicht met week/maand tabellen
  - Grafische visualisaties
  - Persoonlijke en restaurant statistieken
- 📱 **Responsive design** (web, tablet, mobiel)
- 📑 **Export functionaliteit** (PDF, CSV, Excel)

## 🛠️ Technische Stack

- **Frontend**: Flutter Web
- **State Management**: Provider
- **Data Visualisatie**: fl_chart
- **Styling**: Material Design
- **Containerization**: Docker
- **Data Tables**: data_table_2
- **Logging**: logger

## 🏗️ Project Structuur

```plaintext
lib/
├── models/       # Data models
├── providers/    # State management
├── screens/      
│   ├── annual_overview/    # Jaar/maand/week overzichten
│   ├── home/              # Dashboard & tijdregistratie
│   └── debug/             # API documentatie
├── services/     # API services
├── utils/        # Helper functies
└── widgets/      # Herbruikbare widgets
```

## 🚦 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 of hoger)
- Docker (optioneel, voor containerization)

### Lokale Ontwikkeling

1. Clone de repository:
   ```bash
   git clone https://github.com/yourusername/urcs.git
   ```
2. Installeer de dependencies:
   ```bash
   flutter pub get
   ```
3. Start de applicatie:
   ```bash
   flutter run -d chrome
   ```

### Docker Development

Start de development container:
```bash
docker-compose up --build
```
De applicatie is beschikbaar op: [http://localhost:8080](http://localhost:8080)

### Docker Production

Build en start de productie container:
```bash
docker-compose -f docker-compose.prod.yml up --build
```
De applicatie is beschikbaar op: [http://localhost:80](http://localhost:80)

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

## 📚 API Documentatie

De API documentatie is beschikbaar binnen de applicatie via:
1. Start de applicatie
2. Navigeer naar het menu
3. Selecteer "API Documentation"

De documentatie toont alle beschikbare endpoints, request/response formaten en authenticatie vereisten.

## 📝 Contact

Project Link: [https://github.com/yourusername/urcs](https://github.com/yourusername/urcs)
