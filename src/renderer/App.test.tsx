import { App } from "./App";
import { render, screen } from "@testing-library/react";
import { test, expect } from "vitest";

test("renders the renderer sanity text", () => {
  render(<App />);
  expect(screen.getByText("Electron + React + TypeScript")).toBeInTheDocument();
  expect(
    screen.getByText("If you see this, the renderer is working."),
  ).toBeInTheDocument();
});
