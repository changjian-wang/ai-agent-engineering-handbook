import json
import math
import platform
import sys
import unittest
from collections.abc import Iterator, Sequence

import numpy as np
import torch


def iter_batches(rows: list[list[float]], batch_size: int) -> Iterator[list[list[float]]]:
    if batch_size <= 0:
        raise ValueError("batch_size must be positive")
    for start in range(0, len(rows), batch_size):
        yield rows[start:start + batch_size]


def squared_loss(weight: float, bias: float) -> float:
    return (3.0 * weight + bias - 5.0) ** 2


def gradient_example() -> dict[str, float]:
    weight = torch.tensor(2.0, dtype=torch.float64, device="cpu", requires_grad=True)
    bias = torch.tensor(1.0, dtype=torch.float64, device="cpu", requires_grad=True)
    prediction = 3.0 * weight + bias
    loss = (prediction - 5.0).square()
    loss.backward()
    if weight.grad is None or bias.grad is None:
        raise RuntimeError("Expected gradients on leaf parameters")

    step = 1e-6
    report = {
        "loss_before": loss.item(),
        "weight_grad": weight.grad.item(),
        "bias_grad": bias.grad.item(),
        "weight_finite_difference": (
            squared_loss(2.0 + step, 1.0) - squared_loss(2.0 - step, 1.0)
        ) / (2.0 * step),
        "bias_finite_difference": (
            squared_loss(2.0, 1.0 + step) - squared_loss(2.0, 1.0 - step)
        ) / (2.0 * step),
    }
    with torch.no_grad():
        weight -= 0.01 * weight.grad
        bias -= 0.01 * bias.grad
        report["loss_after"] = (3.0 * weight + bias - 5.0).square().item()
    return report


def information_measures(
    reference: Sequence[float], candidate: Sequence[float]
) -> dict[str, float]:
    reference_probs = np.asarray(reference, dtype=np.float64)
    candidate_probs = np.asarray(candidate, dtype=np.float64)
    if reference_probs.ndim != 1 or reference_probs.size == 0:
        raise ValueError("Expected nonempty one-dimensional probabilities")
    if reference_probs.shape != candidate_probs.shape:
        raise ValueError("Probability vectors must have equal shapes")
    for probabilities in (reference_probs, candidate_probs):
        if not np.isfinite(probabilities).all() or (probabilities < 0).any():
            raise ValueError("Probabilities must be finite and nonnegative")
        if not np.isclose(probabilities.sum(), 1.0, rtol=1e-12, atol=1e-12):
            raise ValueError("Probabilities must sum to one")

    positive = reference_probs > 0
    supported_reference = reference_probs[positive]
    supported_candidate = candidate_probs[positive]
    entropy = float(-np.sum(supported_reference * np.log(supported_reference)))
    if (supported_candidate == 0).any():
        return {"entropy": entropy, "cross_entropy": math.inf, "kl": math.inf}
    cross_entropy = float(-np.sum(supported_reference * np.log(supported_candidate)))
    divergence = float(np.sum(
        supported_reference * (np.log(supported_reference) - np.log(supported_candidate))
    ))
    return {"entropy": entropy, "cross_entropy": cross_entropy, "kl": divergence}


def build_report() -> dict[str, object]:
    features = np.array([[1.0, 2.0], [3.0, 4.0]], dtype=np.float64)
    weights = np.array([[2.0], [-1.0]], dtype=np.float64)
    predictions = features @ weights + np.array([0.5], dtype=np.float64)
    vector = np.array([3.0, 4.0])
    direction = np.array([1.0, 0.0])
    projection = (vector @ direction) / (direction @ direction) * direction
    matrix = np.diag([3.0, 1.0])
    left_vectors, singular_values, right_vectors = np.linalg.svd(matrix, full_matrices=False)
    rank_one = (left_vectors[:, :1] * singular_values[:1]) @ right_vectors[:1, :]
    generator = np.random.default_rng(42)
    samples = generator.binomial(1, 0.3, size=1000)
    prior = 0.1
    recall = 0.8
    false_positive_rate = 0.2
    positive_probability = recall * prior + false_positive_rate * (1.0 - prior)
    return {
        "environment": {
            "python": platform.python_version(),
            "platform": platform.system(),
            "numpy": np.__version__,
            "torch": torch.__version__,
            "device": "cpu",
            "dtype": "float64",
            "seed": 42,
            "data": "constructed math examples; not a model benchmark",
        },
        "linear_output": predictions.tolist(),
        "gradient": gradient_example(),
        "projection": projection.tolist(),
        "rank_one_error": float(np.linalg.norm(matrix - rank_one, ord="fro")),
        "posterior": recall * prior / positive_probability,
        "bernoulli_mean": float(samples.mean()),
        "bernoulli_variance": float(samples.var()),
        "information_nats": information_measures([0.75, 0.25], [0.5, 0.5]),
    }


class MathBasicsTests(unittest.TestCase):
    def test_matrix_product_and_bias(self):
        features = np.array([[1.0, 2.0], [3.0, 4.0]])
        weights = np.array([[2.0], [-1.0]])
        expected = np.array([[0.5], [2.5]])
        np.testing.assert_allclose(features @ weights + 0.5, expected)
        torch.testing.assert_close(
            torch.tensor(features) @ torch.tensor(weights) + 0.5,
            torch.tensor(expected),
        )
        self.assertEqual(build_report()["linear_output"], expected.tolist())

    def test_silent_broadcast_trap(self):
        predictions = np.array([[0.5], [2.5]])
        targets = np.array([1.0, 2.0])
        self.assertEqual((predictions - targets).shape, (2, 2))
        residuals = predictions - targets[:, None]
        self.assertEqual(residuals.shape, (2, 1))
        np.testing.assert_allclose(residuals, [[-0.5], [0.5]])

    def test_incompatible_matrix_shapes(self):
        with self.assertRaises(ValueError):
            np.zeros((2, 3)) @ np.zeros((4, 2))
        with self.assertRaises(RuntimeError):
            torch.zeros((2, 3)) @ torch.zeros((4, 2))

    def test_analytic_numerical_and_automatic_gradients(self):
        report = gradient_example()
        self.assertAlmostEqual(report["weight_grad"], 12.0)
        self.assertAlmostEqual(report["bias_grad"], 4.0)
        self.assertAlmostEqual(report["weight_finite_difference"], 12.0, delta=1e-5)
        self.assertAlmostEqual(report["bias_finite_difference"], 4.0, delta=1e-5)
        self.assertAlmostEqual(report["loss_before"], 4.0)
        self.assertAlmostEqual(report["loss_after"], 2.56)
        self.assertAlmostEqual(squared_loss(2.0 - 0.2 * 12.0, 1.0 - 0.2 * 4.0), 36.0)

    def test_gradients_accumulate_and_can_be_reset(self):
        parameter = torch.tensor(2.0, dtype=torch.float64, requires_grad=True)
        parameter.square().backward()
        parameter.square().backward()
        self.assertIsNotNone(parameter.grad)
        self.assertEqual(parameter.grad.item(), 8.0)
        parameter.grad = None
        parameter.square().backward()
        self.assertEqual(parameter.grad.item(), 4.0)

    def test_projection_and_rank_one_approximation(self):
        report = build_report()
        self.assertEqual(report["projection"], [3.0, 0.0])
        self.assertAlmostEqual(report["rank_one_error"], 1.0)

    def test_bayes_and_information_identity(self):
        self.assertAlmostEqual(build_report()["posterior"], 4.0 / 13.0)
        measures = information_measures([0.75, 0.25], [0.5, 0.5])
        self.assertAlmostEqual(measures["entropy"], 0.5623351446188083)
        self.assertAlmostEqual(measures["cross_entropy"], math.log(2))
        self.assertAlmostEqual(measures["cross_entropy"], measures["entropy"] + measures["kl"])
        reverse = information_measures([0.5, 0.5], [0.75, 0.25])
        self.assertNotAlmostEqual(measures["kl"], reverse["kl"])

    def test_zero_probability_conventions(self):
        identical = information_measures([1.0, 0.0], [1.0, 0.0])
        self.assertEqual(identical, {"entropy": 0.0, "cross_entropy": 0.0, "kl": 0.0})
        unsupported = information_measures([0.5, 0.5], [1.0, 0.0])
        self.assertTrue(math.isinf(unsupported["cross_entropy"]))
        self.assertTrue(math.isinf(unsupported["kl"]))

    def test_invalid_probabilities_are_rejected(self):
        for invalid in ([], [0.2, 0.2], [-0.5, 1.5], [math.nan, 1.0]):
            with self.subTest(probabilities=invalid), self.assertRaises(ValueError):
                information_measures(invalid, [0.5, 0.5])
        with self.assertRaises(ValueError):
            information_measures([0.5, 0.5], [1.0])

    def test_seeded_generators_repeat_in_the_same_environment(self):
        first = np.random.default_rng(42).binomial(1, 0.3, size=1000)
        second = np.random.default_rng(42).binomial(1, 0.3, size=1000)
        np.testing.assert_array_equal(first, second)
        first_torch = torch.Generator(device="cpu").manual_seed(42)
        second_torch = torch.Generator(device="cpu").manual_seed(42)
        torch.testing.assert_close(
            torch.rand(8, generator=first_torch),
            torch.rand(8, generator=second_torch),
            rtol=0, atol=0,
        )

    def test_python_iterator_and_json_round_trip(self):
        batches = iter_batches([[1.0], [2.0], [3.0]], 2)
        self.assertEqual([len(batch) for batch in batches], [2, 1])
        self.assertEqual(list(batches), [])
        with self.assertRaises(ValueError):
            list(iter_batches([[1.0]], 0))
        report = build_report()
        self.assertEqual(json.loads(json.dumps(report, allow_nan=False)), report)


if __name__ == "__main__":
    suite = unittest.defaultTestLoader.loadTestsFromTestCase(MathBasicsTests)
    result = unittest.TextTestRunner(verbosity=2).run(suite)
    if not result.wasSuccessful():
        sys.exit(1)
    print(json.dumps(build_report(), indent=2, allow_nan=False))