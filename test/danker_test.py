#!/usr/bin/env python3

"""
danker test cases
"""
import unittest
import pathlib
import os
import sys
import networkx as nx
import numpy as np
import danker

class DankerTest(unittest.TestCase):
    """
    danker test cases
    """

    def _compare(self, netx, dank):
        """
        Helper method to compare danker and NetworkX outputs.
        """
        self.assertEqual(len(netx), len(dank))
        self.assertEqual(len(netx.keys() - dank.keys()), 0)
        self.assertEqual(len(dank.keys() - netx.keys()), 0)
        result = [[], []]
        for i in netx.keys():
            result[0].append(netx.get(i))
            result[1].append(dank.get(i)[1])
        res = np.array(result)
        print("Pearson correlation:")
        print(np.corrcoef(res[0], res[1]))
        self.assertAlmostEqual(np.corrcoef(res[0], res[1])[0][1], 1, places=6)

    def test_main(self):
        """
        Test main method
        """
        sys.argv = [sys.argv[0], './test/graphs/test.links', '0.85', '10', '1']
        danker.danker._main()

    def test_left_sort(self):
        """
        Test if assert for left sort works (test with right sorted file)
        """
        link_file_right = "./test/graphs/test.links.right"
        with self.assertRaises(danker.InputNotSortedException):
            danker.init(link_file_right, 0.1, False, False)

    def test_right_sort(self):
        """
        Test if assert for right sort works (test with left sorted file)
        """
        link_file = "./test/graphs/test.links"
        danker_graph = danker.init(link_file, 0.1, True, False)
        with self.assertRaises(danker.InputNotSortedException):
            danker.danker_smallmem(danker_graph, link_file, 50, 0.85, 0.1, False)

    def test_general(self):
        """
        Test with a very small graph and comparision between danker and NetworkX.
        """
        link_file = "./test/graphs/test.links"
        link_file_right = "./test/graphs/test.links.right"
        nx_graph = nx.read_edgelist(link_file, create_using=nx.DiGraph, nodetype=str,
                                    delimiter='\t')
        nx_pr = nx.pagerank(nx_graph, tol=1e-8)
        danker_graph = danker.init(link_file, 0.1, False, False)
        danker_pr_big = danker.danker_bigmem(danker_graph, 50, 0.85)
        self._compare(nx_pr, danker_pr_big)
        danker_pr_small = danker.danker_smallmem(danker_graph, link_file_right, 50, 0.85, 0.1, False)
        self._compare(nx_pr, danker_pr_small)

    def test_empty(self):
        """
        Test with an empty file
        """
        link_file = "./test/graphs/nill.links"
        link_file_right = "./test/graphs/nill.links.right"
        pathlib.Path(link_file).touch(exist_ok=True)
        pathlib.Path(link_file_right).touch(exist_ok=True)
        danker_graph = danker.init(link_file, 0.1, False, True)
        danker_pr_big = danker.danker_bigmem(danker_graph, 50, 0.85)
        danker_pr_small = danker.danker_smallmem(danker_graph, link_file_right, 50, 0.85, 0.1, True)
        self.assertEqual(len(danker_pr_big) + len(danker_pr_small), 0)

        # cleanup
        os.remove(link_file)
        os.remove(link_file_right)

    def test_bar(self):
        """
        Test with a small graph (Bavarian Wikilinks) and comparision between danker and NetworkX.
        """
        link_file = "./test/graphs/bar-20190301.links"
        link_file_right = "./test/graphs/bar-20190301.links.right"
        nx_graph = nx.read_edgelist(link_file, create_using=nx.DiGraph, nodetype=int,
                                    delimiter='\t')
        nx_pr = nx.pagerank(nx_graph, tol=1e-8)
        danker_graph = danker.init(link_file, 0.1, False, True)
        danker_pr_big = danker.danker_bigmem(danker_graph, 50, 0.85)
        self._compare(nx_pr, danker_pr_big)
        danker_pr_small = danker.danker_smallmem(danker_graph, link_file_right, 50, 0.85, 0.1, True)
        self._compare(nx_pr, danker_pr_small)

if __name__ == '__main__':
    unittest.main()
