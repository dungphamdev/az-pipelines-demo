using System.ComponentModel.DataAnnotations;

namespace AzPipelinesDemo.Models;

public class Product
{
    public int Id { get; set; }

    [Required]
    [StringLength(100)]
    public string Name { get; set; } = string.Empty;

    [StringLength(500)]
    public string? Description { get; set; }

    [Range(0, 999999)]
    public decimal Price { get; set; }
}
