import { Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import { PartiturasProvider } from './context/PartiturasContext'
import ProtectedRoute from './components/auth/ProtectedRoute'
import Layout from './components/layout/Layout'
import HomePage from './pages/HomePage'
import LoginPage from './pages/auth/LoginPage'
import RegisterPage from './pages/auth/RegisterPage'
import DashboardPage from './pages/dashboard/DashboardPage'
import PartiturasPage from './pages/partituras/PartiturasPage'
import EditorPage from './pages/editor/EditorPage'
import PerfilPage from './pages/perfil/PerfilPage'
import ColaboracionesPage from './pages/colaboraciones/ColaboracionesPage'
import './App.css'

function App() {
  return (
    <AuthProvider>
      <PartiturasProvider>
        <Routes>
          {/* Rutas públicas */}
          <Route path="/" element={<Layout />}>
            <Route index element={<HomePage />} />
            <Route path="login" element={<LoginPage />} />
            <Route path="register" element={<RegisterPage />} />
            
            {/* Rutas protegidas */}
            <Route element={<ProtectedRoute />}>
              <Route path="dashboard" element={<DashboardPage />} />
              <Route path="partituras" element={<PartiturasPage />} />
              <Route path="editor" element={<EditorPage />} />
              <Route path="editor/:id" element={<EditorPage />} />
              <Route path="perfil" element={<PerfilPage />} />
              <Route path="colaboraciones" element={<ColaboracionesPage />} />
            </Route>
            
            {/* Ruta 404 */}
            <Route path="*" element={<Navigate to="/" replace />} />
          </Route>
        </Routes>
      </PartiturasProvider>
    </AuthProvider>
  )
}

export default App
