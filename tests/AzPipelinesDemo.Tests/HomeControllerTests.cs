using AzPipelinesDemo.Controllers;
using AzPipelinesDemo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Abstractions;
using Xunit;

namespace AzPipelinesDemo.Tests;

public class HomeControllerTests
{
    [Fact]
    public void Index_ReturnsView()
    {
        var controller = CreateController();

        var result = controller.Index();

        Assert.IsType<ViewResult>(result);
    }

    [Fact]
    public void Privacy_ReturnsView()
    {
        var controller = CreateController();

        var result = controller.Privacy();

        Assert.IsType<ViewResult>(result);
    }

    [Fact]
    public void Error_ReturnsViewWithTraceIdentifier()
    {
        const string traceIdentifier = "test-trace-id";
        var controller = CreateController(traceIdentifier);

        var result = Assert.IsType<ViewResult>(controller.Error());
        var model = Assert.IsType<ErrorViewModel>(result.Model);

        Assert.Equal(traceIdentifier, model.RequestId);
    }

    private static HomeController CreateController(string? traceIdentifier = null)
    {
        var controller = new HomeController(NullLogger<HomeController>.Instance);
        var httpContext = new DefaultHttpContext();

        if (traceIdentifier is not null)
        {
            httpContext.TraceIdentifier = traceIdentifier;
        }

        controller.ControllerContext = new ControllerContext
        {
            HttpContext = httpContext
        };

        return controller;
    }
}
