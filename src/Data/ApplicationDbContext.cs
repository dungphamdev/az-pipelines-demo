using AzPipelinesDemo.Models;
using Microsoft.EntityFrameworkCore;

namespace AzPipelinesDemo.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Product> Products => Set<Product>();
}
