using Xunit;

namespace FailingLib.Tests;

public class FailingTests
{
    [Fact]
    public void Add_DeliberateFailure_ProvesFailurePropagation()
    {
        // Deliberately failing test to verify that CI runner accurately flags failure
        var result = Calculator.Add(2, 2);
        Assert.Equal(999, result);
    }
}
