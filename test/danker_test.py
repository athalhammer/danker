#!/usr/bin/env python3

import unittest
import networkx as nx
import numpy as np
import lib.danker

class DankerTest(unittest.TestCase):

    def _compare(self, netx, danker):
        self.assertEqual(len(netx), len(danker))
        self.assertEqual(len(netx.keys() - danker.keys()), 0)
        self.assertEqual(len(danker.keys() - netx.keys()), 0)
        result = [[], []]
        for i in netx.keys():
            result[0].append(netx.get(i))
            result[1].append(danker.get(i)[1])
        res = np.array(result)
        print("Pearson correlation:")
        print(np.corrcoef(res[0], res[1]))
        self.assertAlmostEqual(np.corrcoef(res[0], res[1])[0][1], 1, places=6)

    def test_general(self):
        link_file = "./test/graphs/test.links"
        link_file_right = "./test/graphs/test.links.right"
        nx_graph = nx.read_edgelist(link_file, create_using=nx.DiGraph, nodetype=str,
                                    delimiter='\t')
        nx_pr = nx.pagerank(nx_graph, tol=1e-8)
        danker_graph = lib.danker.init(link_file, 0.1, False)
        danker_pr_big = lib.danker.danker_bigmem(danker_graph, 50, 0.85)
        self._compare(nx_pr, danker_pr_big)
        danker_pr_small = lib.danker.danker_smallmem(danker_graph, link_file_right, 50, 0.85, 0.1)
        self._compare(nx_pr, danker_pr_small)

    def test_bar(self):
        link_file = "./test/graphs/bar-20190301.links"
        link_file_right = "./test/graphs/bar-20190301.links.right"
        nx_graph = nx.read_edgelist(link_file, create_using=nx.DiGraph, nodetype=int,
                                    delimiter='\t')
        nx_pr = nx.pagerank(nx_graph, tol=1e-8)
        danker_graph = lib.danker.init(link_file, 0.1, False)
        danker_pr_big = lib.danker.danker_bigmem(danker_graph, 50, 0.85)
        self._compare(nx_pr, danker_pr_big)
        danker_pr_small = lib.danker.danker_smallmem(danker_graph, link_file_right, 50, 0.85, 0.1)
        self._compare(nx_pr, danker_pr_small)

if __name__ == '__main__':
    unittest.main()
