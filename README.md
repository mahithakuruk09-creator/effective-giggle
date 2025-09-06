# Scredex Monorepo

This repository contains the Scredex fintech super-app consisting of a Flutter mobile application, FastAPI backend, and shared Dart packages.

## Structure
- `apps/mobile` – Flutter app
- `backend/api` – FastAPI backend API
- `packages/design_system` – shared UI components
- `docs` – project documentation
- `.github/workflows` – CI/CD pipelines

## Getting Started
### Mobile App
```bash
cd apps/mobile
flutter pub get
flutter run
```

### Backend API
```bash
cd backend/api
pip install -r requirements.txt
uvicorn backend.api.main:app --reload
```

## License
Proprietary
