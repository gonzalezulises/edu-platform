# Migraciones y Seeds

## Introducción

Las migraciones permiten versionar cambios en la estructura de la base de datos. Los seeds populan datos iniciales para desarrollo y testing.

## Prisma Migrations

### Crear migración

Después de modificar `schema.prisma`:

```bash
# Crear migración con nombre descriptivo
npx prisma migrate dev --name add_user_role

# Output:
# ✔ Generated Prisma Client
# ✔ The migration 20241201123456_add_user_role has been created
```

Esto crea:
```
prisma/
└── migrations/
    └── 20241201123456_add_user_role/
        └── migration.sql
```

### Archivo de migración

```sql
-- prisma/migrations/20241201123456_add_user_role/migration.sql
-- CreateEnum
CREATE TYPE "Role" AS ENUM ('USER', 'ADMIN', 'MODERATOR');

-- AlterTable
ALTER TABLE "User" ADD COLUMN "role" "Role" NOT NULL DEFAULT 'USER';
```

### Flujo de trabajo

```bash
# 1. Modificar schema.prisma
# 2. Crear migración (desarrollo)
npx prisma migrate dev --name descripcion

# 3. Aplicar en producción
npx prisma migrate deploy
```

### Comandos útiles

```bash
# Ver estado de migraciones
npx prisma migrate status

# Reset completo (¡borra todos los datos!)
npx prisma migrate reset

# Crear migración sin aplicar
npx prisma migrate dev --create-only

# Resolver migración fallida
npx prisma migrate resolve --applied "20241201123456_add_user_role"
```

## Supabase Migrations

### Crear migración

```bash
# Crear archivo de migración vacío
supabase migration new add_user_role
```

Crea:
```
supabase/
└── migrations/
    └── 20241201123456_add_user_role.sql
```

### Escribir SQL

```sql
-- supabase/migrations/20241201123456_add_user_role.sql

-- Crear enum
CREATE TYPE user_role AS ENUM ('user', 'admin', 'instructor');

-- Agregar columna
ALTER TABLE profiles ADD COLUMN role user_role DEFAULT 'user';

-- Crear índice
CREATE INDEX idx_profiles_role ON profiles(role);

-- Actualizar RLS
CREATE POLICY "Admins can view all profiles"
ON profiles FOR SELECT
TO authenticated
USING (
  (SELECT role FROM profiles WHERE id = auth.uid()) = 'admin'
);
```

### Aplicar migraciones

```bash
# Ver estado
SUPABASE_ACCESS_TOKEN=$TOKEN supabase migration list

# Aplicar a producción
SUPABASE_ACCESS_TOKEN=$TOKEN supabase db push

# Aplicar localmente
supabase db reset  # Reset + apply all migrations
```

## Seeding

### Prisma Seed

```tsx
// prisma/seed.ts
import { PrismaClient } from '@prisma/client'
import bcrypt from 'bcryptjs'

const prisma = new PrismaClient()

async function main() {
  console.log('🌱 Seeding database...')

  // Limpiar datos existentes (orden importante por FKs)
  await prisma.enrollment.deleteMany()
  await prisma.lesson.deleteMany()
  await prisma.module.deleteMany()
  await prisma.course.deleteMany()
  await prisma.user.deleteMany()

  // Crear usuarios
  const adminPassword = await bcrypt.hash('admin123', 10)
  const admin = await prisma.user.create({
    data: {
      email: 'admin@example.com',
      name: 'Admin User',
      password: adminPassword,
      role: 'ADMIN',
    },
  })

  const instructorPassword = await bcrypt.hash('instructor123', 10)
  const instructor = await prisma.user.create({
    data: {
      email: 'instructor@example.com',
      name: 'Jane Instructor',
      password: instructorPassword,
      role: 'INSTRUCTOR',
    },
  })

  // Crear curso con módulos y lecciones
  const course = await prisma.course.create({
    data: {
      title: 'Next.js 14 Completo',
      description: 'Aprende Next.js desde cero hasta producción',
      slug: 'nextjs-14-completo',
      instructorId: instructor.id,
      isPublished: true,
      modules: {
        create: [
          {
            title: 'Introducción',
            orderIndex: 1,
            lessons: {
              create: [
                {
                  title: 'Bienvenida',
                  content: 'Contenido de bienvenida...',
                  duration: 300,
                  orderIndex: 1,
                },
                {
                  title: 'Instalación',
                  content: 'Cómo instalar...',
                  duration: 600,
                  orderIndex: 2,
                },
              ],
            },
          },
          {
            title: 'App Router',
            orderIndex: 2,
            lessons: {
              create: [
                {
                  title: 'Rutas básicas',
                  content: 'Explicación de rutas...',
                  duration: 900,
                  orderIndex: 1,
                },
              ],
            },
          },
        ],
      },
    },
  })

  // Crear estudiantes de prueba
  for (let i = 1; i <= 5; i++) {
    const password = await bcrypt.hash(`student${i}`, 10)
    await prisma.user.create({
      data: {
        email: `student${i}@example.com`,
        name: `Student ${i}`,
        password,
        role: 'USER',
      },
    })
  }

  console.log('✅ Seed completed!')
  console.log(`   Created admin: ${admin.email}`)
  console.log(`   Created instructor: ${instructor.email}`)
  console.log(`   Created course: ${course.title}`)
}

main()
  .catch((e) => {
    console.error(e)
    process.exit(1)
  })
  .finally(async () => {
    await prisma.$disconnect()
  })
```

### Configurar en package.json

```json
{
  "prisma": {
    "seed": "tsx prisma/seed.ts"
  }
}
```

```bash
# Instalar tsx para ejecutar TypeScript
npm install -D tsx

# Ejecutar seed
npx prisma db seed

# O con reset (borra y vuelve a crear)
npx prisma migrate reset  # Automáticamente ejecuta seed
```

### Supabase Seed

```sql
-- supabase/seed.sql

-- Insertar roles
INSERT INTO roles (id, name) VALUES
  ('role_admin', 'admin'),
  ('role_instructor', 'instructor'),
  ('role_student', 'student');

-- Insertar usuario admin
INSERT INTO auth.users (id, email, encrypted_password, email_confirmed_at)
VALUES (
  'admin-uuid',
  'admin@example.com',
  crypt('admin123', gen_salt('bf')),
  NOW()
);

INSERT INTO profiles (id, email, name, role_id)
VALUES (
  'admin-uuid',
  'admin@example.com',
  'Admin User',
  'role_admin'
);

-- Insertar curso de ejemplo
INSERT INTO courses (id, title, slug, description, is_published)
VALUES (
  'course-1',
  'Next.js 14 Completo',
  'nextjs-14-completo',
  'Aprende Next.js desde cero',
  true
);

-- Insertar módulos
INSERT INTO modules (id, course_id, title, order_index) VALUES
  ('mod-1', 'course-1', 'Introducción', 1),
  ('mod-2', 'course-1', 'App Router', 2),
  ('mod-3', 'course-1', 'Data Fetching', 3);

-- Insertar lecciones
INSERT INTO lessons (id, module_id, title, duration, order_index) VALUES
  ('les-1', 'mod-1', 'Bienvenida', 300, 1),
  ('les-2', 'mod-1', 'Instalación', 600, 2),
  ('les-3', 'mod-2', 'Rutas básicas', 900, 1);
```

```bash
# Aplicar seed
supabase db reset  # Aplica migraciones + seed
```

## Migraciones de datos

A veces necesitas migrar datos existentes:

```sql
-- Migration: Separar nombre en first_name y last_name
-- supabase/migrations/20241202_split_name.sql

-- 1. Agregar nuevas columnas
ALTER TABLE profiles
ADD COLUMN first_name TEXT,
ADD COLUMN last_name TEXT;

-- 2. Migrar datos
UPDATE profiles
SET
  first_name = split_part(name, ' ', 1),
  last_name = CASE
    WHEN array_length(string_to_array(name, ' '), 1) > 1
    THEN substring(name from position(' ' in name) + 1)
    ELSE ''
  END;

-- 3. Hacer columnas NOT NULL (después de migrar)
ALTER TABLE profiles
ALTER COLUMN first_name SET NOT NULL,
ALTER COLUMN last_name SET NOT NULL;

-- 4. (Opcional) Eliminar columna vieja
-- ALTER TABLE profiles DROP COLUMN name;
```

## Rollback de migraciones

### Prisma

Prisma no tiene rollback automático. Crea una nueva migración para revertir:

```bash
# Marcar migración como revertida manualmente
npx prisma migrate resolve --rolled-back "20241201123456_add_user_role"
```

### Supabase

```bash
# Revertir última migración (solo local)
supabase migration squash --local
```

O crear migración de rollback:

```sql
-- supabase/migrations/20241203_revert_split_name.sql
ALTER TABLE profiles DROP COLUMN first_name;
ALTER TABLE profiles DROP COLUMN last_name;
```

## Buenas prácticas

1. **Nombres descriptivos**: `add_user_role`, `create_courses_table`
2. **Migraciones pequeñas**: Una cambio lógico por migración
3. **Test local primero**: `migrate dev` o `db reset`
4. **Backup antes de producción**: Siempre
5. **No modificar migraciones aplicadas**: Crea nuevas
6. **Seeds idempotentes**: Pueden ejecutarse múltiples veces

## Checklist de deploy

```bash
# 1. Backup de producción
pg_dump $DATABASE_URL > backup_$(date +%Y%m%d).sql

# 2. Test en staging
npx prisma migrate deploy

# 3. Deploy a producción
npx prisma migrate deploy

# 4. Verificar
npx prisma migrate status
```
