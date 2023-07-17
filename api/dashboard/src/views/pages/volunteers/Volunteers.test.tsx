import React from "react";

import { act, render, screen } from "@testing-library/react";
import { Mock, vi } from "vitest";

import { getVolunteerList } from "../../../Controllers/VolunteersControllers/VolunteersApi";

import Volunteers from "./Volunteers";

vi.mock("../../../Controllers/VolunteersControllers/VolunteersApi", () => {
  return { getVolunteerList: vi.fn() };
});

const flushPromises = (): Promise<void> => new Promise(setImmediate);

vi.mock("react-router", () => {
  const useNavigate = vi.fn(() => vi.fn());
  return { useNavigate };
});

describe("Volunteer Page test", () => {
  afterEach(() => {
    vi.clearAllMocks();
  });

  it("shows message about no entries", async () => {
    await (getVolunteerList as Mock).mockRejectedValueOnce({
      response: { data: { error: { message: "" } } },
    });
    render(<Volunteers />);

    expect(getVolunteerList).toBeCalledWith({
      limit: 10,
      offset: 0,
      orderBy: "id asc",
      filter: {},
    });

    await act(flushPromises);

    const linkElement = screen.getByText("No items found");
    expect(linkElement).not.toBeNull();
  });

  it("shows volunteers in table", async () => {
    (getVolunteerList as Mock).mockResolvedValueOnce({
      data: [{ email: "asfawefasdf", verified: true, name: "41231faewa" }],
    });
    render(<Volunteers />);
    expect(getVolunteerList).toBeCalledWith({
      limit: 10,
      offset: 0,
      orderBy: "id asc",
      filter: {},
    });

    await act(flushPromises);

    const linkElement = screen.queryByText("asfawefasdf");
    expect(linkElement).not.toBeNull();
  });
});
