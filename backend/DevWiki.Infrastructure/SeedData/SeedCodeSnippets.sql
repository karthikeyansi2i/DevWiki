-- Seed Code Snippets for existing articles
-- This script creates sample snippets for articles that exist in the DB

DO $$
DECLARE
    article_record RECORD;
    snippet_count INT;
BEGIN
    SELECT count(*) INTO snippet_count FROM public."CodeSnippets";
    IF snippet_count > 0 THEN
        RAISE NOTICE 'CodeSnippets already seeded, skipping.';
        RETURN;
    END IF;

    FOR article_record IN SELECT "ArticleId", "Title" FROM public."Articles" LIMIT 10 LOOP
        -- DI article
        IF article_record."Title" ILIKE '%DI%' OR article_record."Title" ILIKE '%Dependency%' THEN
            INSERT INTO public."CodeSnippets" ("SnippetId", "ArticleId", "Title", "Description", "Language", "Code", "CreatedBy", "UpdatedBy", "CreatedAt", "UpdatedAt")
            VALUES
            (gen_random_uuid(), article_record."ArticleId", 'AddScoped', 'Creates a scoped service - one instance per request', 'C#',
             'services.AddScoped<IUserService, UserService>();' || E'\n' || '// Created once per HTTP request scope',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW()),
            (gen_random_uuid(), article_record."ArticleId", 'AddSingleton', 'Creates a singleton service - one instance for the application lifetime', 'C#',
             'services.AddSingleton<ICacheService, MemoryCacheService>();' || E'\n' || '// Created once, shared across all requests',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW()),
            (gen_random_uuid(), article_record."ArticleId", 'AddTransient', 'Creates a transient service - new instance every time', 'C#',
             'services.AddTransient<INotificationService, EmailNotificationService>();' || E'\n' || '// Created every time it is requested',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW());
        END IF;

        -- EF Core article
        IF article_record."Title" ILIKE '%EF%' OR article_record."Title" ILIKE '%Entity%' OR article_record."Title" ILIKE '%Framework%' THEN
            INSERT INTO public."CodeSnippets" ("SnippetId", "ArticleId", "Title", "Description", "Language", "Code", "CreatedBy", "UpdatedBy", "CreatedAt", "UpdatedAt")
            VALUES
            (gen_random_uuid(), article_record."ArticleId", 'Include()', 'Eagerly loads related entities', 'C#',
             'var article = await context.Articles' || E'\n' || '    .Include(a => a.Author)' || E'\n' || '    .Include(a => a.Category)' || E'\n' || '    .FirstOrDefaultAsync(a => a.ArticleId == id);',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW()),
            (gen_random_uuid(), article_record."ArticleId", 'AsNoTracking()', 'Disables change tracking for read-only queries', 'C#',
             'var articles = await context.Articles' || E'\n' || '    .AsNoTracking()' || E'\n' || '    .Where(a => a.Status == ArticleStatus.Active)' || E'\n' || '    .ToListAsync();',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW()),
            (gen_random_uuid(), article_record."ArticleId", 'ExecuteUpdate()', 'Bulk update without loading entities', 'C#',
             'await context.Articles' || E'\n' || '    .Where(a => a.CategoryId == oldCategoryId)' || E'\n' || '    .ExecuteUpdateAsync(setters => setters' || E'\n' || '        .SetProperty(a => a.CategoryId, newCategoryId));',
             (SELECT "UserId" FROM public."Users" LIMIT 1), NULL, NOW(), NOW());
        END IF;
    END LOOP;

    RAISE NOTICE 'Code snippets seeded successfully.';
END $$;
