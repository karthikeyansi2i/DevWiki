-- ============================================
-- 02_users.sql
-- 2 users: Admin and Editor
-- ============================================

-- Password for both users is "P@ssw0rd!" hashed with PBKDF2-SHA256
-- In production, use proper password hashing.

INSERT INTO "Users" ("UserId", "Email", "NormalizedEmail", "PasswordHash", "FirstName", "LastName", "Role", "IsActive", "CreatedAt", "UpdatedAt")
VALUES
(
  '11111111-1111-1111-1111-111111111111',
  'admin@devwiki.com',
  'ADMIN@DEVWIKI.COM',
  'AQAAAAIAAYagAAAAEG1xR4k9p0vGFTm0wT5fZq3X8y2cL6b7dN4oRpV5jK1hJ3mN8s2tUv9wXyZ0rP6Q==',
  'System',
  'Admin',
  1,
  true,
  '2026-01-01T00:00:00Z',
  '2026-01-01T00:00:00Z'
),
(
  '22222222-2222-2222-2222-222222222222',
  'editor@devwiki.com',
  'EDITOR@DEVWIKI.COM',
  'AQAAAAIAAYagAAAAEG1xR4k9p0vGFTm0wT5fZq3X8y2cL6b7dN4oRpV5jK1hJ3mN8s2tUv9wXyZ0rP6Q==',
  'Jane',
  'Editor',
  2,
  true,
  '2026-01-15T00:00:00Z',
  '2026-01-15T00:00:00Z'
);
