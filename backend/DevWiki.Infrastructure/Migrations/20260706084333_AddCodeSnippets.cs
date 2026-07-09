using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DevWiki.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddCodeSnippets : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CodeSnippets",
                columns: table => new
                {
                    SnippetId = table.Column<Guid>(type: "uuid", nullable: false),
                    ArticleId = table.Column<Guid>(type: "uuid", nullable: false),
                    Title = table.Column<string>(type: "character varying(255)", maxLength: 255, nullable: false),
                    Description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    Language = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Code = table.Column<string>(type: "text", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: false),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CodeSnippets", x => x.SnippetId);
                    table.ForeignKey(
                        name: "FK_CodeSnippets_Articles_ArticleId",
                        column: x => x.ArticleId,
                        principalTable: "Articles",
                        principalColumn: "ArticleId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_CodeSnippets_Users_CreatedBy",
                        column: x => x.CreatedBy,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_CodeSnippets_Users_UpdatedBy",
                        column: x => x.UpdatedBy,
                        principalTable: "Users",
                        principalColumn: "UserId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CodeSnippets_ArticleId",
                table: "CodeSnippets",
                column: "ArticleId");

            migrationBuilder.CreateIndex(
                name: "IX_CodeSnippets_CreatedAt",
                table: "CodeSnippets",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_CodeSnippets_CreatedBy",
                table: "CodeSnippets",
                column: "CreatedBy");

            migrationBuilder.CreateIndex(
                name: "IX_CodeSnippets_Language",
                table: "CodeSnippets",
                column: "Language");

            migrationBuilder.CreateIndex(
                name: "IX_CodeSnippets_UpdatedBy",
                table: "CodeSnippets",
                column: "UpdatedBy");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "CodeSnippets");
        }
    }
}
